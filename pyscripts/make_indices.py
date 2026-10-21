#!/usr/bin/env python3
import argparse
import glob
import os
import re

import requests
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import check_for_hash
from acdh_xml_pyutils.xml import NSMAP

PMB_BASE = "https://pmb.acdh.oeaw.ac.at/entity/"
PMB_URI_RE = re.compile(
    r"^https://pmb\.acdh\.oeaw\.ac\.at/entity/(\d+)/?$"
)
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


# Command-line arguments
parser = argparse.ArgumentParser()

parser.add_argument(
    "-r",
    "--retry",
    nargs="?",
    const=1,
    default=0,
    type=int,
    metavar="N",
    help="Retry failed requests N times (default: 1 if specified).",
)

args = parser.parse_args()

if args.retry < 0:
    parser.error("--retry must be a non-negative integer")


# 1. Collect IDs referenced in the editions.
ids = set()

for f in glob.glob("./data/editions/*.xml"):
    doc = TeiReader(f)

    for ref_attr in doc.any_xpath("//@ref[starts-with(., '#pmb')]"):
        for ref in ref_attr.split():
            ids.add(check_for_hash(ref).replace("pmb", ""))


# 2. Cache canonical IDs and track failed requests.
#
# CANONICAL:
#     nominal ID -> canonical ID (or fallback ID if unresolved)
#
# FAILED:
#     nominal ID used for the request -> aliases belonging to the entity
#
# UNRESOLVED:
#     IDs whose canonical mapping is only a temporary fallback

CANONICAL = {}
FAILED = {}
UNRESOLVED = set()


def request_canonical(nominal_id):
    """Request the canonical PMB ID for a nominal ID."""
    response = requests.get(
        f"{PMB_BASE}{nominal_id}/?format=json",
        timeout=30,
    )
    response.raise_for_status()

    canonical = response.json()["id"]

    if canonical is None:
        raise ValueError("PMB response contains no canonical ID")

    return str(canonical)


def resolve(nominal_ids):
    """Resolve an entity's aliases, recording failed requests."""
    if not nominal_ids:
        return None

    # Return a cached result only if it is not a temporary fallback.
    for nominal_id in nominal_ids:
        if (
            nominal_id in CANONICAL
            and nominal_id not in UNRESOLVED
        ):
            return CANONICAL[nominal_id]

    # Avoid issuing another request for an already pending failure.
    for nominal_id in nominal_ids:
        if nominal_id in FAILED:
            return CANONICAL.get(nominal_id, nominal_id)

    nominal_id = nominal_ids[0]

    try:
        canonical = request_canonical(nominal_id)

    except Exception as exc:
        print(f"Could not resolve {nominal_id}: {exc}")

        FAILED[nominal_id] = list(nominal_ids)
        UNRESOLVED.update(nominal_ids)

        # Use the nominal ID as a temporary fallback.
        canonical = nominal_id

    else:
        # A successful request resolves all aliases for this entity.
        UNRESOLVED.difference_update(nominal_ids)

    for alias in nominal_ids:
        CANONICAL[alias] = canonical

    CANONICAL[canonical] = canonical

    if canonical not in UNRESOLVED:
        UNRESOLVED.discard(canonical)

    return canonical


def retry_failed(remaining):
    """Retry failed requests, updating canonical mappings on success."""
    if remaining <= 0 or not FAILED:
        return

    pending = list(FAILED.items())
    FAILED.clear()

    print(
        f"\nRetry round: {args.retry - remaining + 1}/{args.retry}; "
        f"{len(pending)} request(s) to retry."
    )

    for nominal_id, nominal_ids in pending:
        try:
            canonical = request_canonical(nominal_id)

        except Exception as exc:
            print(f"Retry failed for {nominal_id}: {exc}")

            # Only requests that fail again remain pending.
            FAILED[nominal_id] = nominal_ids

        else:
            print(f"Resolved {nominal_id} -> {canonical}")

            # Update every alias associated with this entity.
            for alias in nominal_ids:
                CANONICAL[alias] = canonical
                UNRESOLVED.discard(alias)

            CANONICAL[canonical] = canonical
            UNRESOLVED.discard(canonical)

    # Retry again only if failures remain and attempts are available.
    retry_failed(remaining - 1)


# 3. Load and filter the source indices.
#
# Keep the XML documents in memory until all retries have finished.
# This ensures that successful retries are reflected in the output.

documents = []

for index in INDICES:
    print(f"Processing {index['file_name']}")

    try:
        doc = TeiReader(index["url"])

    except Exception as exc:
        print(f"Problem reading {index['url']}: {exc}")
        continue

    entities = []

    for ent in doc.any_xpath(index["entity_xpath"]):
        pmb_idnos = []

        for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
            match = PMB_URI_RE.match((idno.text or "").strip())

            if match:
                pmb_idnos.append((idno, match.group(1)))

        nominal_ids = [nominal_id for _, nominal_id in pmb_idnos]

        # Retain only entities referenced in the editions.
        relevant = [
            nominal_id
            for nominal_id in nominal_ids
            if nominal_id in ids
        ]

        if not relevant:
            ent.getparent().remove(ent)
            continue

        # Resolve now; failures are recorded for the retry phase.
        resolve(relevant)

        entities.append((ent, pmb_idnos, relevant))

    documents.append((index, doc, entities))


# 4. Retry failed requests, if requested.
if args.retry:
    retry_failed(args.retry)

if FAILED:
    print(
        f"\n{len(FAILED)} request(s) remain unresolved "
        f"after {args.retry} retry attempt(s)."
    )
else:
    print("\nAll canonical ID requests resolved successfully.")


# 5. Finalise entities and write the output files.
os.makedirs(INDICES_DIR, exist_ok=True)

for index, doc, entities in documents:
    print(f"Writing {index['file_name']}")

    seen_ids = set()

    for ent, pmb_idnos, relevant in entities:
        # Retrieve the final canonical ID, including successful retries.
        canonical = resolve(relevant)

        if canonical in seen_ids:
            ent.getparent().remove(ent)
            continue

        seen_ids.add(canonical)

        # Normalise the entity's XML ID.
        ent.attrib[XML_ID] = f"pmb{canonical}"

        # Keep the first PMB idno and normalise its URI.
        # Remove additional PMB aliases.
        for i, (idno, _) in enumerate(pmb_idnos):
            if i == 0:
                idno.text = f"{PMB_BASE}{canonical}/"
            else:
                idno.getparent().remove(idno)

        # Remove remaining duplicate idnos, e.g. case-insensitive DOI duplicates.
        seen_idno_values = set()

        for idno in ent.xpath("./tei:idno", namespaces=NSMAP):
            value = (idno.text or "").strip().lower()

            if value in seen_idno_values:
                idno.getparent().remove(idno)
            else:
                seen_idno_values.add(value)

    save_path = os.path.join(INDICES_DIR, index["file_name"])

    try:
        doc.tree_to_file(save_path)

    except Exception as exc:
        print(f"Problem writing {save_path}: {exc}")