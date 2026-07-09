#!/usr/bin/env python
import argparse
import re
from lxml import etree

def extract_pmb_refs(xmlfiles):
    pattern = re.compile(r"#pmb([^\s]+)")
    refs = set()

    for xmlfile in xmlfiles:
        tree = etree.parse(xmlfile)

        for elem in tree.xpath("//*[@ref]"):
            ref = elem.get("ref")
            refs.update(pattern.findall(ref))
    return {f"#{x}" for x in refs}

def filter_relations(relations_file, output_file, pmb_refs):
    tree = etree.parse(relations_file)

    ns = {"tei": "http://www.tei-c.org/ns/1.0"}

    relations = tree.xpath("//tei:relation", namespaces=ns)

    for rel in relations:
        active = rel.get("active", "").split()
        passive = rel.get("passive", "").split()

        
        if not (pmb_refs.intersection(active) or pmb_refs.intersection(passive)):
            rel.getparent().remove(rel)
    etree.indent(tree, space="  ")
    tree.write(
        output_file,
        encoding="UTF-8",
        xml_declaration=True,
        pretty_print=True
    )


def main():
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

    args = parser.parse_args()
    
    pmb_refs = extract_pmb_refs(args.xmlfiles)

    filter_relations(
        args.relations,
        args.output,
        pmb_refs
    )


if __name__ == "__main__":
    main()