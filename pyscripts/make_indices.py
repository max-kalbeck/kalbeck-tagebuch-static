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

PMB_URIS = [
    {"uri": f"https://pmb.acdh.oeaw.ac.at/entity/{x}/", "pmb_id": f"pmb{x}"}
    for x in ids
]

for x in INDICES:
    print(f"processing {x['file_name']}")
    save_path = os.path.join(INDICES_DIR, x["file_name"])
    doc = TeiReader(x["url"])
    for ent in doc.any_xpath(f"{x['entity_xpath']}"):
        uris = ent.xpath("./tei:idno/text()", namespaces=NSMAP)
        for pmb_uri in PMB_URIS:
            if pmb_uri["uri"] in uris:
                ent.attrib["{http://www.w3.org/XML/1998/namespace}id"] = pmb_uri[  # noqa
                    "pmb_id"
                ]
                break
        else:
            ent.getparent().remove(ent)

    doc.tree_to_file(save_path)
