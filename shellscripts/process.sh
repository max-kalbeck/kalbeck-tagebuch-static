# bin/bash
uv run add-attributes -g "./data/editions/*.xml" -b "https://kalbeck-tagebuch.acdh.oeaw.ac.at"
uv run add-attributes -g "./data/meta/*.xml" -b "https://kalbeck-tagebuch.acdh.oeaw.ac.at"

uv run pyscripts/make_indices.py
uv run denormalize-indices -f "./data/editions/*.xml" -i "./data/indices/*.xml"  -x ".//tei:title[@level='a']/text()"