# bin/bash
uv run add-attributes -g "./data/editions/*.xml" -b "https://kalbeck-tagebuch.acdh.oeaw.ac.at"
uv run add-attributes -g "./data/meta/*.xml" -b "https://kalbeck-tagebuch.acdh.oeaw.ac.at"