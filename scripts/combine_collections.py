import json
import os

os.chdir(os.getcwd() + '\\..')

cookedPath = 'assets/cooked/'
outPath = cookedPath + 'combined.json'

if os.path.exists(outPath):
    os.remove(outPath)

if not os.path.exists(cookedPath):
    os.makedirs(cookedPath)

with open('assets/words-collections/base.json', 'r', encoding='utf-8') as content_file:
    content = content_file.read()

collection_list = json.loads(content)

new_collections = []

for collection_desc in collection_list['collections']:
    print('Processing collection {}'.format(collection_desc['path']))

    with open(collection_desc['path'], 'r', encoding='utf-8') as collection_file:
        collection_content = collection_file.read()

    new_collections.append(json.loads(collection_content))

collection_list['collections'] = new_collections

with open(outPath, 'a', encoding='utf-8') as out_file:
    out_file.write(json.dumps(collection_list, ensure_ascii=False))


