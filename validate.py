import re
import json
import os

warningsCount = 0
words_set = set()
en_translations_set = set()

images_path = 'assets/images/words/compressed'

def check_cyrillic(text):
    if (bool(re.search('[а-яА-Я]', text))):
        global warningsCount
        warningsCount += 1
        print ('WARNING: {} contains cyrillic!'.format(text))

def check_latin(text):
    if (bool(re.search('[a-zA-Z]', text))):
        global warningsCount
        warningsCount += 1
        print ('WARNING: {} contains latin!'.format(text))

def check_duplicate(text):
    if (text in words_set):
        global warningsCount
        warningsCount += 1
        print ('WARNING: duplicate {}'.format(text))
    else:
        words_set.add(text)

def check_duplicate_translation(text):
    if (text in en_translations_set):
        global warningsCount
        warningsCount += 1
        print ('WARNING: duplicate EN translation {}'.format(text))
    else:
        en_translations_set.add(text)

def check_image_exists(collection, filename):
    joined_path = os.path.join(images_path, collection, filename + '.webp')
    if (not os.path.exists(joined_path)):
        global warningsCount
        warningsCount += 1
        print ('WARNING: image does not exist {}'.format(joined_path))

with open('assets/words-collections/base.json', 'r', encoding='utf8') as content_file:
    content = content_file.read()

collection_list = json.loads(content)

for collection_desc in collection_list['collections']:
    print('Processing collection {}'.format(collection_desc['path']))

    en_translations_set.clear()

    with open(collection_desc['path'], 'r', encoding='utf-8') as collection_file:
        collection_content = collection_file.read()

    collection = json.loads(collection_content)
    collection_name = collection['name']

    check_latin(collection_name)

    words = collection['words']

    words_count = 0

    for word in words:
        words_count += 1
        en_translation = words[word]['en']
        image_path = en_translation
        if ('imgOverride' not in words[word]):
            check_duplicate_translation(en_translation)
        else:
            image_path = words[word]['imgOverride']
        check_duplicate(word)
        check_latin(word)
        check_latin(words[word]['ru'])
        check_cyrillic(en_translation)

        check_image_exists(collection['imgDir'], image_path)

    print('Words in the collection: {}'.format(words_count))

print('Total warnings: {}'.format(warningsCount))
print('Total words count: {}'.format(len(words_set)))