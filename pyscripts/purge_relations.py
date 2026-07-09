#!/usr/bin/env python
import argparse
import re
from lxml import etree

def extract_pmb_refs(xmlfile):
    tree = etree.parse(xmlfile)

    pattern = re.compile(r"#pmb([^\s]+)")

    refs = set()

    for elem in tree.xpath("//*[@ref]"):
        ref = elem.get("ref")
        refs.update(pattern.findall(ref))

    return refs


def main():
    parser = argparse.ArgumentParser(
        description="Extract all @ref values matching #pmbX from TEI XML files"
    )
    parser.add_argument(
        "xmlfiles",
        nargs="+",
        help="One or more TEI XML files"
    )
    args = parser.parse_args()

    pmb_refs = set()

    for xmlfile in args.xmlfiles:
        pmb_refs.update(extract_pmb_refs(xmlfile))
        
    for ref in sorted(pmb_refs):
        print(ref)



if __name__ == "__main__":
    main()