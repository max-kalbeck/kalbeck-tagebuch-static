#!/usr/bin/env python3
import glob
import os

import requests
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import check_for_hash
from acdh_xml_pyutils.xml import NSMAP
from functools import lru_cache


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
            
            
@lru_cache(maxsize=None)
def get_canonical_pmb_id(entity_id):
    """Return the canonical PMB ID, accounting for merged entities."""
    url = f"https://pmb.acdh.oeaw.ac.at/entity/{entity_id}/?format=json"
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return f"pmb{response.json()['id']}"
    

PMB_URI_TO_ID = {}
for x in ids:
    canonical_id = get_canonical_pmb_id(x)
    PMB_URI_TO_ID[f"https://pmb.acdh.oeaw.ac.at/entity/{x}/"] = canonical_id

for x in INDICES:
    print(f"processing {x['file_name']}")
    save_path = os.path.join(INDICES_DIR, x["file_name"])
    try:
        doc = TeiReader(x["url"])
        seen_ids = set()
        for ent in doc.any_xpath(f"{x['entity_xpath']}"):
            uris = ent.xpath("./tei:idno/text()", namespaces=NSMAP)
            for uri in  ["https://pmb.acdh.oeaw.ac.at/entity/50/",
                        "https://pmb.acdh.oeaw.ac.at/entity/2316/",
                        "https://pmb.acdh.oeaw.ac.at/entity/20954/",
                        "https://pmb.acdh.oeaw.ac.at/entity/65221/",
                        "https://pmb.acdh.oeaw.ac.at/entity/65223/"
                        ]:
                if uri in uris:
                    print("x['url']", x["url"])
                    print('uris', uris)
                    print('uri, PMB_URI_TO_ID[uri]', uri,  PMB_URI_TO_ID[uri])
                
            pmb_id = next(
                (PMB_URI_TO_ID[uri] for uri in uris if uri in PMB_URI_TO_ID), None
            )
            # drop entities with no matching pmb id, and any repeat of an id already kept
            if pmb_id is None or pmb_id in seen_ids:
                ent.getparent().remove(ent)
                continue
            ent.attrib["{http://www.w3.org/XML/1998/namespace}id"] = pmb_id

            # drop idno duplicates within this entity, e.g. the same DOI recorded
            # with differing letter case
            seen_idno_values = set()
            for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
                value = (idno.text or "").strip().lower()
                if value in seen_idno_values:
                    idno.getparent().remove(idno)
                else:
                    seen_idno_values.add(value)
            seen_ids.add(pmb_id)

        doc.tree_to_file(save_path)
    except Exception:
        print(f"Problem reading {x["url"]}")