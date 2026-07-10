#!/usr/bin/env python
"""
Dies macht drei Schritte:
1. PMB-Referenzen aus TEI-Dateien einsammeln,
2. relations.xml auf relevante Kanten reduzieren,
3. daraus eine kompakte JSON-Struktur bauen.
"""

import argparse
import json
from urllib.request import Request, urlopen
from acdh_tei_pyutils.tei import TeiReader


def parse_relation_ids(rel, attr_name):
    """Liest IDs aus einem Relationsattribut und normalisiert sie.

    Erwartet z.B. active/passive-Werte wie '#pmb123' oder '#123'
    und liefert nur die nackte PMB-ID zurueck.
    """
    values = rel.get(attr_name, "").split()
    return [value.strip("#") for value in values if value.strip()]


def make_entity_payload(entity_id, is_extern):
    """Baut den JSON-Grundblock für eine Entitaet.

    'extern' ist True, wenn die ID nicht in den lokalen PMB-Referenzen vorkommt.
    Die URL richtet sich danach (PMB extern vs. lokale HTML-Seite).
    """
    
    if is_extern:
        url = f"https://pmb.acdh.oeaw.ac.at/entity/{entity_id}"
    else:
        url = f"pmb{entity_id}.html"
    return {
        "url": url,
        "extern": "False",
        "img": "",""
        "relations": {},
    }


def generate_json(relations_input, output_file):
    """Erzeugt die JSON-Reprasentation der gefilterten Relationen.

    relations_input kann entweder ein TeiReader-Objekt oder ein Dateipfad sein.
    Die JSON-Datei wird neben der XML-Ausgabe abgelegt.
    """
    
    exclude_types = ["veranstaltungsort-von", "ist-urauffuhrung-von", "veranstaltet", "enthalt", "angesiedelt-in", "in-relation-zu"]

    if isinstance(relations_input, TeiReader):
        doc = relations_input
    else:
        doc = TeiReader(relations_input)

    relations = doc.any_xpath("//tei:relation")
    relations_dict = {}

    for rel in relations:
        relation_name = rel.get("name", "")
        active_ids = parse_relation_ids(rel, "active")
        passive_ids = parse_relation_ids(rel, "passive")
        is_extern = rel.get("subtype", "")
        

        if not relation_name or not active_ids or not passive_ids:
            continue

        for entity_id in active_ids + passive_ids:
            if entity_id  not in relations_dict:
                relations_dict.setdefault(entity_id, make_entity_payload(entity_id, is_extern))
                if entity_id in  active_ids and relation_name not in exclude_types:
                     relations_dict[entity_id]["img"] = get_image_url(entity_id)
                    

        for active_id in active_ids:
            entity_relations = relations_dict[active_id]["relations"].setdefault(
                relation_name,
                [],
            )
               
            for passive_id in passive_ids:
                if passive_id not in entity_relations:
                    entity_relations.append(passive_id)

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(relations_dict, f, ensure_ascii=False, indent=2)

    return relations_dict


def get_image_url(pmbid):
    """Liest die Bild-URL aus der PMB-API fuer eine Person.

    Es wird das JSON unter pmb_json_url geladen und der Wert von `img_url`
    zurueckgegeben. Falls kein Wert vorhanden ist, kommt None zurueck.
    """
    req = Request(f"https://pmb.acdh.oeaw.ac.at/apis/api/entities/person/{pmbid}/?format=json",
                  headers={"Accept": "application/json"}
                  )
    with urlopen(req) as response:
        payload = json.loads(response.read().decode("utf-8"))

    img_url = payload.get("img_url")
    if not img_url:
        return False
    return img_url

def parse_args():
    parser = argparse.ArgumentParser(
        description="Extract PMB refs from TEI files and filter relations.xml"
    )

    parser.add_argument(
        "xmlfile",
        help="TEI XML file containing @ref attributes"
    )

    parser.add_argument(
        "-o", "--output",
        required=True,
        help="output filtered relations XML file"
    )

    return parser.parse_args()


def main():
    args = parse_args()
    xml_doc = TeiReader(args.xmlfile)
    generate_json(xml_doc, args.output)


if __name__ == "__main__":
    main()