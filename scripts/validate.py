import re
import json
import os

rootPath = os.path.join(os.getcwd(), '..')
os.chdir(rootPath)

warningsCount = 0
words_set = set()
ids_set = set()

images_path = 'assets/cooked/images'


def check_cyrillic(text):
    if bool(re.search('[а-яА-Я]', text)):
        global warningsCount
        warningsCount += 1
        print('WARNING: {} contains cyrillic!'.format(text))


def check_latin(text):
    if bool(re.search('[a-zA-Z]', text)):
        global warningsCount
        warningsCount += 1
        print('WARNING: {} contains latin!'.format(text))


def check_duplicate_by(text):
    if text in words_set:
        global warningsCount
        warningsCount += 1
        print('WARNING: duplicate {}'.format(text))
    else:
        words_set.add(text)


def check_duplicate_ids(text):
    if text in ids_set:
        global warningsCount
        warningsCount += 1
        print('WARNING: duplicate ID {}'.format(text))
    else:
        ids_set.add(text)


def check_image_exists(l_collection, filename):
    joined_path = os.path.join(images_path, l_collection, filename + '.webp')
    if not os.path.exists(joined_path):
        global warningsCount
        warningsCount += 1
        print('WARNING: image does not exist {}'.format(joined_path))


with open('assets/words-collections/base.json', 'r', encoding='utf8') as content_file:
    content = content_file.read()

collection_list = json.loads(content)

for collection_desc in collection_list['collections']:
    print('Processing collection {}'.format(collection_desc['path']))

    with open(collection_desc['path'], 'r', encoding='utf-8') as collection_file:
        collection_content = collection_file.read()

    collection = json.loads(collection_content)
    collection_name = collection['name']

    check_latin(collection_name)

    words = collection['words']

    words_count = 0

    for word in words:
        words_count += 1

        by_word = words[word]['by']

        check_duplicate_ids(word)
        check_duplicate_by(by_word)
        check_cyrillic(word)
        check_latin(by_word)
        check_latin(words[word]['ru'])
        check_cyrillic(words[word]['en'])

        check_image_exists(collection['imgDir'], word)

    print('Words in the collection: {}'.format(words_count))

print('Total warnings: {}'.format(warningsCount))
print('Total words count: {}'.format(len(words_set)))
