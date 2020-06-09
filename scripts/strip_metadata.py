#Скрипт вырезает метаданные из png изображений.
#Используется в системе Spritesheet

import os, sys
from PIL import Image

if __name__ == "__main__":
    if len (sys.argv) > 1:
        path = sys.argv[1]
        image = Image.open(path)
        image.save(path)
