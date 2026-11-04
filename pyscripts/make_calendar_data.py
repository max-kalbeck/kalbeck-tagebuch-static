#!/usr/bin/env python
import glob
import os
import json
import re
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm

# matches pages whose body text consists of nothing but a weekday name,
# e.g. "Freitag." or "Mittwoch" (optionally followed by a period)
WEEKDAY_ONLY_RE = re.compile(
    r'^(Montag|Dienstag|Mittwoch|Donnerstag|Freitag|Samstag|Sonnabend|Sonntag)\.?$'
)


def is_empty_entry(doc):
    """an entry counts as empty if its body contains no text besides
    the <head> (the date) and, optionally, the day of the week"""
    texts = doc.any_xpath('//tei:body//text()[not(ancestor::tei:head)]')
    body_text = re.sub(r'\s+', ' ', ''.join(texts)).strip()
    return body_text == '' or bool(WEEKDAY_ONLY_RE.match(body_text))


files = glob.glob('./data/editions/*xml')
out_file = "./html/calendarData.json"
data = []
for x in tqdm(files, total=len(files)):
    item = {}
    head, tail = os.path.split(x)
    doc = TeiReader(x)
    item['name'] = doc.any_xpath('//tei:title[@level="a"]/text()')[0]
    item['startDate'] = doc.any_xpath('//tei:title[@type="iso-date"]/@when-iso')[0]
    item['id'] = tail.replace('.xml', '.html')
    item['isEmpty'] = is_empty_entry(doc)
    data.append(item)

print(f"writing calendar data to {out_file}")
with open(out_file, 'w',  encoding='utf8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
