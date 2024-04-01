import json
import os

out_filename = '../flat_list.txt'

with open('../assets/words-collections/base.json', 'r', encoding='utf8') as content_file:
    content = content_file.read()

collection_list = json.loads(content)

if os.path.exists(out_filename):
    os.remove(out_filename)

with open(out_filename, 'a', encoding='utf-8') as out_file:
    for collection_desc in collection_list['collections']:
        print('Processing collection {}'.format(collection_desc['path']))

        with open(collection_desc['path'], 'r', encoding='utf-8') as collection_file:
            collection_content = collection_file.read()

        collection = json.loads(collection_content)

        words = collection['words']

        out_file.write('\n{} Count: {}\n'.format(collection['name'], len(words)))

        for key, value in words.items():
            print('Word: {}'.format(key))
            out_file.write('{}\n'.format(value['by']))
