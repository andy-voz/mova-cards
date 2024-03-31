import json
import os
import shutil

from PIL import Image

originalsDir = 'assets/images/words/originals/'
compressedDir = 'assets/images/words/compressed/'

if os.path.exists(compressedDir):
    shutil.rmtree(compressedDir)

os.mkdir(compressedDir)

with open('assets/words-collections/base.json', 'r', encoding='utf8') as content_file:
    content = content_file.read()

collection_list = json.loads(content)

for collection_desc in collection_list['collections']:
    print('Processing collection {}'.format(collection_desc['path']))

    with open(collection_desc['path'], 'r', encoding='utf-8') as collection_file:
        collection_content = collection_file.read()

    collection = json.loads(collection_content)

    print('Successfully loaded json for {}'.format(collection['name']))

    img_dir = collection['imgDir']

    for word_id in collection['words']:
        image_name = word_id

        # Reading image from original file
        imageFile = os.path.join(originalsDir, img_dir, image_name + '.jpg')

        if (not os.path.exists(imageFile)):
            imageFile = os.path.join(originalsDir, img_dir, image_name + '.png')

        if (not os.path.exists(imageFile)):
            print('WARN: File for {} doesn\'t exist!'.format(image_name))
            continue

        image = Image.open(imageFile)

        # Cropping image to have symmetric width, height.
        width, height = image.size
        diff = 0
        if width > height:
            diff = width - height
            image = image.crop((diff / 2, 0, width - diff / 2, height))
            image.load
        elif height > width:
            diff = height - width
            image = image.crop((0, diff / 2, width, height - diff / 2))
            image.load

        # Now image is a square 300x300.

        # Resizing
        image = image.resize((300, 300))

        # Saving image with compression.
        new_dir = os.path.join(compressedDir, img_dir)
        if not os.path.exists(new_dir):
            os.mkdir(new_dir)

        new_path = os.path.join(new_dir, image_name + '.webp')
        image.save(new_path, format='webp', optimize=True, quality=90)
