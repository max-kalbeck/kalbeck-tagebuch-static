import glob
import os
from copy import deepcopy

import typesense
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import (
    extract_fulltext,
    get_xmlid,
    make_entity_label,
)
from tqdm import tqdm
from typesense.exceptions import ObjectNotFound

COLLECTION_NAME = "kalbeck-tagebuch-static"
files = glob.glob("./data/editions/*.xml")
TEI_NS = "http://www.tei-c.org/ns/1.0"
PB_TAG = f"{{{TEI_NS}}}pb"
P_TAG = f"{{{TEI_NS}}}p"
tag_blacklist = [
    f"{{{TEI_NS}}}abbr",
    f"{{{TEI_NS}}}del",
]
namespaces = {"tei": "http://www.tei-c.org/ns/1.0"}


TYPESENSE_API_KEY = os.environ.get("TYPESENSE_API_KEY", "xyz")
TYPESENSE_TIMEOUT = os.environ.get("TYPESENSE_TIMEOUT", "120")
TYPESENSE_HOST = os.environ.get("TYPESENSE_HOST", "localhost")
TYPESENSE_PORT = os.environ.get("TYPESENSE_PORT", "8108")
TYPESENSE_PROTOCOL = os.environ.get("TYPESENSE_PROTOCOL", "http")
client = typesense.Client(
    {
        "nodes": [
            {
                "host": TYPESENSE_HOST,
                "port": TYPESENSE_PORT,
                "protocol": TYPESENSE_PROTOCOL,
            }
        ],
        "api_key": TYPESENSE_API_KEY,
        "connection_timeout_seconds": int(TYPESENSE_TIMEOUT),
    }
)


try:
    client.collections[COLLECTION_NAME].delete()
except ObjectNotFound:
    pass

current_schema = {
    "name": COLLECTION_NAME,
    "metadata": {
        "owners": ["Peter Andorfer", "Fernando Sanz-Lázaro"],
        "description": "'Max Kalbeck Tagebuch' (https://github.com/max-kalbeck/kalbeck-tagebuch-static)",
        "service_ids": [26167],
    },
    "enable_nested_fields": True,
    "fields": [
        {"name": "id", "type": "string"},
        {"name": "rec_id", "type": "string", "sort": True},
        {"name": "paragraph_index", "type": "int32", "sort": True},
        {"name": "page_index", "type": "int32", "sort": True},
        {"name": "title", "type": "string"},
        {"name": "page_label", "type": "string"},
        {"name": "url", "type": "string"},
        {"name": "full_text", "type": "string"},
        {"name": ".*_entities", "type": "auto", "facet": True, "optional": True},
    ],
}

client.collections.create(current_schema)


def iter_paragraph_records(body, base_record):
    """Yield one Typesense record per TEI paragraph in document order."""
    page_index = 0
    page_label = ""
    paragraph_index = 0

    for node in body.iter():
        if node.tag == PB_TAG:
            page_index += 1
            page_label = node.get("n") or str(page_index)
            continue

        if node.tag != P_TAG:
            continue

        paragraph_index += 1
        paragraph_record = deepcopy(base_record)
        paragraph_record["id"] = f"{base_record['id']}-p-{paragraph_index}"
        paragraph_record["paragraph_index"] = paragraph_index
        paragraph_record["page_index"] = page_index
        paragraph_record["page_label"] = page_label
        paragraph_record["url"] = f"{base_record['rec_id']}.html#p-{paragraph_index}"
        paragraph_record["full_text"] = extract_fulltext(node, tag_blacklist=tag_blacklist)
        yield paragraph_record


records = []
for x in tqdm(files, total=len(files)):
    doc = TeiReader(x)
    try:
        body = doc.any_xpath(".//tei:body")[0]
    except IndexError:
        continue
    base_record = {}
    base_record["id"] = os.path.split(x)[-1].replace(".xml", "")
    base_record["rec_id"] = os.path.split(x)[-1].replace(".xml", "")
    base_record["title"] = doc.any_xpath(".//tei:titleStmt/tei:title[@level='a']")[0].text

    base_record["person_entities"] = []
    for y in doc.any_xpath(".//tei:back//tei:listPerson/tei:person[@xml:id]"):
        item = {}
        item["id"] = get_xmlid(y)
        item["label"] = make_entity_label(
            y.xpath("./tei:persName[1]", namespaces=namespaces)[0]
        )[0]
        base_record["person_entities"].append(item)

    base_record["place_entities"] = []
    for y in doc.any_xpath(".//tei:back//tei:listPlace/tei:place[@xml:id]"):
        item = {}
        item["id"] = get_xmlid(y)
        item["label"] = make_entity_label(
            y.xpath("./tei:placeName[1]", namespaces=namespaces)[0]
        )[0]
        base_record["place_entities"].append(item)

    base_record["org_entities"] = []
    for y in doc.any_xpath(".//tei:back//tei:listOrg/tei:org[@xml:id]"):
        item = {}
        item["id"] = get_xmlid(y)
        item["label"] = make_entity_label(
            y.xpath("./tei:orgName[1]", namespaces=namespaces)[0]
        )[0]
        base_record["org_entities"].append(item)

    base_record["bibl_entities"] = []
    for y in doc.any_xpath(".//tei:back//tei:listBibl/tei:bibl[@xml:id]"):
        item = {}
        item["id"] = get_xmlid(y)
        item["label"] = extract_fulltext(
            y.xpath("./tei:title", namespaces=namespaces)[0]
        )
        base_record["bibl_entities"].append(item)

    records.extend(iter_paragraph_records(body, base_record))


make_index = client.collections[COLLECTION_NAME].documents.import_(records)
print(make_index)
print("done with indexing")
