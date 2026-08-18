#!/bin/bash
uv run pyscripts/purge_relations.py -r data/extern/relations.xml -o data/extern/relations.xml  data/editions/*xml
for index in data/indices/*.xml ; do
		uv run pyscripts/enrich_index.py -r data/extern/relations.xml -i ${index}
done
