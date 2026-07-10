#!/usr/bin/env python
"""
Dies macht drei Schritte:
1. PMB-Referenzen aus TEI-Dateien einsammeln,
2. relations.xml auf relevante Kanten reduzieren,
3. daraus eine kompakte JSON-Struktur bauen.
"""

import argparse
import lxml.etree as ET
import re

from acdh_tei_pyutils.tei import TeiReader


def normalize_id(value):
    """Bereinigt eine PMB-ID auf die reine numerische Zeichenkette."""
    normalized = value.strip().lstrip("#")
    if normalized.startswith("pmb"):
        normalized = normalized[3:]
    return normalized


def extract_pmb_refs(xmlfiles):
    """Sammelt alle PMB-Referenzen aus @ref-Attributen der Eingabedateien."""
    pattern = re.compile(r"#pmb([^\s]+)")
    refs = set()

    for xmlfile in xmlfiles:
        doc = TeiReader(xmlfile)

        for elem in doc.any_xpath("//*[@ref]"):
            ref = elem.get("ref")
            refs.update(pattern.findall(ref))

    return {f"#{x}" for x in refs}


def filter_relations(relations_file, output_file, pmb_refs):
    """Filtert relation-Knoten auf relevante PMB-Bezüge.

    Eine Relation bleibt nur dann erhalten, wenn wenigstens eine aktive oder passive
    Referenz in pmb_refs enthalten ist. Zusaetzlich bekommt jede verbleibende
    Relation ein @subtype mit "intern" oder "extern".
    """
    doc = TeiReader(relations_file)
    relations = doc.any_xpath("//tei:relation")

    for rel in relations:
        active = rel.get("active", "").split()
        passive = rel.get("passive", "").split()

        if not (pmb_refs.intersection(active) or pmb_refs.intersection(passive)):
            rel.getparent().remove(rel)
            continue

        if all(ref in pmb_refs for ref in active):
            rel.set("subtype", "intern")
        else:
            rel.set("subtype", "extern")

    ET.indent(doc.tree, space="  ")
    doc.tree.write(
        output_file,
        encoding="UTF-8",
        xml_declaration=True,
        pretty_print=True,
    )
    return doc


def parse_args():
    parser = argparse.ArgumentParser(
        description="Extract PMB refs from TEI files and filter relations.xml"
    )

    parser.add_argument(
        "xmlfiles",
        nargs="+",
        help="TEI XML files containing @ref attributes"
    )

    parser.add_argument(
        "-r", "--relations",
        required=True,
        help="relations.xml file"
    )

    parser.add_argument(
        "-o", "--output",
        required=True,
        help="output filtered relations XML file"
    )

    return parser.parse_args()


def main():
    args = parse_args()

    pmb_refs = extract_pmb_refs(args.xmlfiles)

    filter_relations(
        args.relations,
        args.output,
        pmb_refs,
    )
    

if __name__ == "__main__":
    main()