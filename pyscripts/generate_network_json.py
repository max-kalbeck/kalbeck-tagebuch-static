#!/usr/bin/env python
"""Erzeugt das JSON-Payload für die Entitäten-Netzwerkseite.

Aufruf:
    generate_network_json.py \
        [-o|--out <output_file>] \
        <index_file.xml> <index_file.xml> ... <index_file.xml>
"""

import argparse
import json
from pathlib import Path
from typing import Any

from acdh_tei_pyutils.tei import TeiReader


TEI_NS = "http://www.tei-c.org/ns/1.0"
XML_NS = "http://www.w3.org/XML/1998/namespace"
NSMAP = {"tei": TEI_NS}
ENTITY_XPATH = "//tei:text/tei:body/*[starts-with(local-name(), 'list')]/*"
RELATION_ID_ATTRS = {"active", "passive"}
RELATION_TYPE_ENTITY_ALIASES = {
    "bibl": "work",
}


def _local_name(tag: str) -> str:
    """Gibt den lokalen XML-Namen ohne Namespace zurück."""
    return tag.rsplit("}", 1)[-1]


def _norm_text(text: str) -> str:
    """Normalisiert Leerzeichen auf genau einen Zwischenraum."""
    return " ".join(text.split())


def _to_pmb_id(value: str) -> str:
    """Normalisiert eine ID auf das Format pmbXXXX (ohne '#')."""
    clean = value.strip().lstrip("#")
    if clean.lower().startswith("pmb"):
        clean = clean[3:]
    return f"pmb{clean}" if clean else ""


def _pmb_id_set(values: str) -> set[str]:
    """Parst eine ID-Liste in eine Menge normalisierter pmb-IDs."""
    return {_to_pmb_id(token) for token in values.split() if token.strip()}


def _relation_type_for_entity(relation_type: str, entity_type: str) -> str:
    """Leitet den Gegen-Typ relativ zur aktuellen Entität ab.

    Beispiel: relation_type='personwork' und entity_type='person' -> 'work'.
    """
    rel_t = relation_type.strip()
    ent_t = entity_type.strip()
    if not rel_t or not ent_t:
        return rel_t

    if rel_t.startswith(ent_t):
        counterpart = rel_t[len(ent_t):]
        return counterpart or rel_t

    if rel_t.endswith(ent_t):
        counterpart = rel_t[:-len(ent_t)]
        return counterpart or rel_t

    return rel_t


def _relation_entity_type(entity_type: str) -> str:
    """Mappt Entitätstypen auf das Token-Schema der Relations-Typen."""
    return RELATION_TYPE_ENTITY_ALIASES.get(entity_type, entity_type)


def _extract_name(entity) -> str:
    """Liefert den Text des ersten direkten *Name-Kindelements."""
    node = next((child for child in entity if _local_name(child.tag).endswith("Name")), None)
    return _norm_text("".join(node.itertext())) if node is not None else ""


def _relation_data(rel, entity_type: str) -> dict[str, str]:
    """Normalisiert Referenzattribute und reduziert den Relations-Typ."""
    rel_data = {
        key: (
            " ".join(_to_pmb_id(token) for token in value.split() if token.strip())
            if key in RELATION_ID_ATTRS
            else value
        )
        for key, value in rel.attrib.items()
    }
    rel_data["type"] = _relation_type_for_entity(rel_data.get("type", ""), entity_type)
    return rel_data


def _extract_relations(entity, entity_id: str, entity_type: str) -> dict[str, list[dict[str, str]]]:
    """Teilt Relationen in active/passive und entfernt den impliziten Schlüssel."""
    relations: dict[str, list[dict[str, str]]] = {"active": [], "passive": []}
    list_relation = entity.find("tei:listRelation", namespaces=NSMAP)
    if list_relation is None:
        return relations

    entity_pmb_id = _to_pmb_id(entity_id)
    for rel in list_relation:
        rel_data = _relation_data(rel, entity_type)
        active_ids = _pmb_id_set(rel_data.get("active", ""))
        passive_ids = _pmb_id_set(rel_data.get("passive", ""))

        if entity_pmb_id in active_ids:
            relations["active"].append({k: v for k, v in rel_data.items() if k != "active"})

        if entity_pmb_id in passive_ids:
            relations["passive"].append({k: v for k, v in rel_data.items() if k != "passive"})

    return relations


def generate_network_payload(args) -> list[dict[str, Any]]:
    """Liest alle XML-Dateien und baut das Netzwerk-Payload auf."""
    payload: list[dict[str, Any]] = []

    for xmlfile in args.xmlfiles:
        doc = TeiReader(xmlfile)
        entities = doc.any_xpath(ENTITY_XPATH)

        for entity in entities:
            entity_type = _local_name(entity.tag)
            relation_entity_type = _relation_entity_type(entity_type)
            parent = entity.getparent()
            list_type = _local_name(parent.tag) if parent is not None else ""
            xml_id = entity.get(f"{{{XML_NS}}}id", "")
            payload.append(
                {
                    "type": entity_type,
                    "list_type": list_type,
                    "id": _to_pmb_id(xml_id),
                    "name": _extract_name(entity),
                    "relations": _extract_relations(entity, xml_id, relation_entity_type),
                }
            )

    return payload


def write_json(path: Path, data: object) -> None:
    """Schreibt das Ergebnis als formatiertes UTF-8-JSON."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fp:
        json.dump(data, fp, ensure_ascii=False, indent=2)


# ----------------------------
# CLI
# ----------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Erzeugt JSON-Daten für die Netzwerkseite")

    parser.add_argument(
        "xmlfiles",
        nargs="+",
        help="TEI-XML-Dateien mit Entitäten unter list*/*",
    )
    parser.add_argument(
        "-o", "--out",
        type=Path,
        default=Path("network.json"),
        help="Ausgabedatei für das Netzwerk-JSON (Standard: %(default)s)",
    )
    return parser


def main(argv: list[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)

    write_json(args.out, generate_network_payload(args))


if __name__ == "__main__":
    main()