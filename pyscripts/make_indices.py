#!/usr/bin/env python3
import glob
import os
import re

import requests
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

os.makedirs(INDICES_DIR, exist_ok=True)
for f in glob.glob(f"{INDICES_DIR}/*.xml"):
    os.remove(f)

# 1. ids referenced in the editions
ids = set()
for f in glob.glob("./data/editions/*.xml"):
    doc = TeiReader(f)
    for ref_attr in doc.any_xpath("//@ref[starts-with(., '#pmb')]"):
        for y in ref_attr.split():
            ids.add(check_for_hash(y).replace("pmb", ""))

# 2. nominal id -> canonical id, filled on demand (one request per relevant entity)
CANONICAL = {}


def resolve(nominal_ids):
    """Canonical id for a group of aliases; requests only the first unknown one."""
    for n in nominal_ids:
        if n in CANONICAL:
            return CANONICAL[n]
    n = nominal_ids[0]
    try:
        r = requests.get(f"{PMB_BASE}{n}/?format=json", timeout=30)
        r.raise_for_status()
        canonical = str(r.json()["id"])
    except Exception as e:
        print(f"Could not resolve {n}: {e}")
        canonical = n
    for m in nominal_ids:  # all aliases of this entity share the canonical id
        CANONICAL[m] = canonical
    CANONICAL[canonical] = canonical
    return canonical


# 3. build the list files
for x in INDICES:
    print(f"processing {x['file_name']}")
    save_path = os.path.join(INDICES_DIR, x["file_name"])
    try:
        doc = TeiReader(x["url"])
        seen_ids = set()
        for ent in doc.any_xpath(x["entity_xpath"]):
            pmb_idnos = []
            for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
                m = PMB_URI_RE.match((idno.text or "").strip())
                if m:
                    pmb_idnos.append((idno, m.group(1)))
            nominal = [n for _, n in pmb_idnos]

            # relevant only if one of the aliases is used in the editions
            relevant = [n for n in nominal if n in ids]
            if not relevant:
                ent.getparent().remove(ent)
                continue

            # at most one request, and only for a referenced alias
            canonical = resolve(relevant)
            if canonical in seen_ids:
                ent.getparent().remove(ent)
                continue
            seen_ids.add(canonical)
            ent.attrib[XML_ID] = f"pmb{canonical}"

            # keep the first pmb idno as canonical, drop the other aliases
            for i, (idno, _) in enumerate(pmb_idnos):
                if i == 0:
                    idno.text = f"{PMB_BASE}{canonical}/"
                else:
                    idno.getparent().remove(idno)

            # drop remaining duplicate idnos (e.g. DOI differing by case)
            seen_idno_values = set()
            for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
                value = (idno.text or "").strip().lower()
                if value in seen_idno_values:
                    idno.getparent().remove(idno)
                else:
                    seen_idno_values.add(value)

        doc.tree_to_file(save_path)
    except Exception as e:
        print(f"Problem reading {x['url']}: {e}")