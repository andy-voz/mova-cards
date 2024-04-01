import os

print('Converting images\n')
os.system('python convert_images.py')
print('Combining words into a one file\n')
os.system('python combine_collections.py')
print('Validating\n')
os.system('python validate.py')
