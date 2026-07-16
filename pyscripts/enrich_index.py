#!/usr/bin/env python
"""Reichert ein bestehendes TEI-Register mit relation-Knoten aus relations.xml an."""

import argparse
from copy import deepcopy

from acdh_tei_pyutils.tei import TeiReader
import lxml.etree as ET

TEI_NS = "http://www.tei-c.org/ns/1.0"
XML_NS = "http://www.w3.org/XML/1998/namespace"


def normalize_id(value):
    """Normalisiert IDs wie '#123', '#pmb123' oder 'pmb123' auf '123'."""
    normalized = value.strip().lstrip("#")
    if normalized.startswith("pmb"):
        normalized = normalized[3:]
    return normalized


def entity_lookup_keys(xml_id):
    """Liefert alle Suchschlüssel fuer ein Entity-@xml:id zurück."""
    clean = xml_id.strip().lstrip("#")
    keys = {clean, normalize_id(clean)}
    return {x for x in keys if x}


def parse_relation_ids(rel, attr_name):
    """Extrahiert und normalisiert IDs aus @active bzw. @passive."""
    values = rel.get(attr_name, "").split()
    return {normalize_id(value) for value in values if value.strip()}


def relation_signature(rel):
    """Stabile Signatur, um doppelte relation-Einträge zu vermeiden."""
    return ET.tostring(rel, encoding="unicode")


def ensure_list_relation(entity):
    """Stellt sicher, dass ein Entity ein Kind <listRelation> hat."""
    list_rel = entity.find(f"{{{TEI_NS}}}listRelation")
    if list_rel is None:
        list_rel = ET.SubElement(entity, f"{{{TEI_NS}}}listRelation")
    return list_rel


def enrich_index(relations_file, index_file, output_file):
    """Fügt passende relation-Knoten in das angegebene TEI-Register ein."""
    relations_doc = TeiReader(relations_file)
    index_doc = TeiReader(index_file)

    id_to_entities = {}
    for entity in index_doc.any_xpath("//*[@xml:id]"):
        xml_id = entity.get(f"{{{XML_NS}}}id")
        if not xml_id:
            continue
        for key in entity_lookup_keys(xml_id):
            id_to_entities.setdefault(key, []).append(entity)

    appended = 0
    list_relation_signatures = {}
    for rel in relations_doc.any_xpath("//tei:relation"):
        target_ids = parse_relation_ids(rel, "active") | parse_relation_ids(rel, "passive")
        if not target_ids:
            continue

        sig = relation_signature(rel)
        for target_id in target_ids:
            for entity in id_to_entities.get(target_id, []):
                list_rel = ensure_list_relation(entity)

                list_rel_key = id(list_rel)
                if list_rel_key not in list_relation_signatures:
                    list_relation_signatures[list_rel_key] = {
                        relation_signature(existing_rel)
                        for existing_rel in list_rel.findall(f"{{{TEI_NS}}}relation")
                    }

                if sig in list_relation_signatures[list_rel_key]:
                    continue

                list_rel.append(deepcopy(rel))
                list_relation_signatures[list_rel_key].add(sig)
                appended += 1

    ET.indent(index_doc.tree, space="  ")
    index_doc.tree.write(
        output_file,
        encoding="UTF-8",
        xml_declaration=True,
        pretty_print=True,
    )
    return appended


def parse_args():
    parser = argparse.ArgumentParser(
        description="Enrich a TEI entity index with relations from relations.xml"
    )

    parser.add_argument(
        "-r", "--relations",
        required=True,
        help="Relations file (e.g.. data/extern/relations.xml)"
    )

    parser.add_argument(
        "-i",
        "--index",
        required=True,
        help="Entity index (e.g. data/indices/listperson.xml)"
    )

    parser.add_argument(
        "-o", "--output",
        required=False,
        help="Output file. If not provided, the enrichment is made in place)"
    )

    return parser.parse_args()


def main():
    args = parse_args()
    output_file = args.output or args.index
    enrich_index(args.relations, args.index, output_file)


if __name__ == "__main__":
    main()
