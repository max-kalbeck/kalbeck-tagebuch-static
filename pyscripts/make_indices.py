#!/usr/bin/env python3
import glob
import os

from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import check_for_hash
from acdh_xml_pyutils.xml import NSMAP

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

for x in glob.glob(f"{INDICES_DIR}/*.xml"):
    os.remove(x)


files = glob.glob("./data/editions/*.xml")


ids = set()
for x in files:
    doc = TeiReader(x)
    for x in doc.any_xpath("//@ref[starts-with(., '#pmb')]"):
        for y in x.split():
            ref = check_for_hash(y)
            ids.add(ref.replace("pmb", ""))

PMB_URI_TO_ID = {
    f"https://pmb.acdh.oeaw.ac.at/entity/{x}/": f"pmb{x}" for x in ids
}

for x in INDICES:
    print(f"processing {x['file_name']}")
    save_path = os.path.join(INDICES_DIR, x["file_name"])
    print(x["url"])
    try:
        doc = TeiReader(x["url"])
        seen_ids = set()
        for ent in doc.any_xpath(f"{x['entity_xpath']}"):
            uris = ent.xpath("./tei:idno/text()", namespaces=NSMAP)
            pmb_id = next(
                (PMB_URI_TO_ID[uri] for uri in uris if uri in PMB_URI_TO_ID), None
            )
            # drop entities with no matching pmb id, and any repeat of an id already kept
            if pmb_id is None or pmb_id in seen_ids:
                ent.getparent().remove(ent)
                continue
            ent.attrib["{http://www.w3.org/XML/1998/namespace}id"] = pmb_id
            seen_ids.add(pmb_id)

        doc.tree_to_file(save_path)
    except Exception:
        print(f"Problem reading {x["url"]}")

