# bin/bash

echo "fetching transkriptions from data_repo"
rm -rf data/
curl -LO https://github.com/max-kalbeck/kalbeck-tagebuch-data/archive/refs/heads/main.zip
unzip main

mv ./kalbeck-tagebuch-data-main/data/ .

rm main.zip
rm -rf ./kalbeck-tagebuch-data-main

echo "fetch imprint"
./shellscripts/dl_imprint.sh
