#!/usr/bin/env python3
import glob
import os
import re

from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import check_for_hash
from acdh_xml_pyutils.xml import NSMAP

PMB_BASE = "https://pmb.acdh.oeaw.ac.at/entity/"
PMB_URI_RE = re.compile(r"^https://pmb\.acdh\.oeaw\.ac\.at/entity/(\d+)/?$")
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"

INDICES_DIR = os.path.join("data", "indices")

INDICES = [
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listbibl.xml",
        "title": "Werkregister",
        "file_name": "listbibl.xml",
        "entity_xpath": ".//tei:bibl[@xml:id]",
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listperson.xml",
        "title": "Personenregister",
        "file_name": "listperson.xml",
        "entity_xpath": ".//tei:person[@xml:id]",
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listplace.xml",
        "title": "Ortsregister",
        "file_name": "listplace.xml",
        "entity_xpath": ".//tei:place[@xml:id]",
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listorg.xml",
        "title": "Institutionsregister",
        "file_name": "listorg.xml",
        "entity_xpath": ".//tei:org[@xml:id]",
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listevent.xml",
        "title": "Ereignisregister",
        "file_name": "listevent.xml",
        "entity_xpath": ".//tei:event[@xml:id]",
    },
]


# 1. Collect IDs referenced in the editions.
ids = set()

for f in glob.glob("./data/editions/*.xml"):
    doc = TeiReader(f)

    for ref_attr in doc.any_xpath("//@ref[starts-with(., '#pmb')]"):
        for ref in ref_attr.split():
            ids.add(check_for_hash(ref).replace("pmb", ""))


# 2. Load the indices, filter, and normalise.
#
# An entity lists all of its PMB aliases as <idno subtype="pmb">.
# The canonical ID is the lowest numeric one.
os.makedirs(INDICES_DIR, exist_ok=True)

for index in INDICES:
    print(f"Processing {index['file_name']}")

    try:
        doc = TeiReader(index["url"])
    except Exception as exc:
        print(f"Problem reading {index['url']}: {exc}")
        continue

    seen_ids = set()

    for ent in doc.any_xpath(index["entity_xpath"]):
        pmb_idnos = []

        for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
            match = PMB_URI_RE.match((idno.text or "").strip())

            if match:
                pmb_idnos.append((idno, match.group(1)))

        # Retain only entities referenced in the editions.
        if not any(nominal_id in ids for _, nominal_id in pmb_idnos):
            ent.getparent().remove(ent)
            continue

        canonical = str(min(int(nominal_id) for _, nominal_id in pmb_idnos))

        # Drop entities whose canonical ID was already emitted.
        if canonical in seen_ids:
            ent.getparent().remove(ent)
            continue

        seen_ids.add(canonical)

        # Normalise the entity's XML ID.
        ent.attrib[XML_ID] = f"pmb{canonical}"

        # Keep only the canonical PMB idno; remove the other aliases.
        kept = False
        for idno, nominal_id in pmb_idnos:
            if nominal_id == canonical and not kept:
                idno.text = f"{PMB_BASE}{canonical}/"
                kept = True
            else:
                idno.getparent().remove(idno)

        # Remove remaining duplicate idnos, e.g. case-insensitive DOI duplicates.
        seen_idno_values = set()

        for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
            value = (idno.text or "").strip().lower()

            if value in seen_idno_values:
                idno.getparent().remove(idno)
            else:
                seen_idno_values.add(value)

    save_path = os.path.join(INDICES_DIR, index["file_name"])
    print(f"Writing {save_path}")

    try:
        doc.tree_to_file(save_path)
    except Exception as exc:
        print(f"Problem writing {save_path}: {exc}")