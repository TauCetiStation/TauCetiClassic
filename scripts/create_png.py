#!/usr/bin/env python3

## Saves png from string with pixels in HEX
## Args:
## * Path to save
## * Width
## * Height
## * String with pixels in HEX format (w/o alpha) (e.g. '#FF0000#00FF00#0000FF#FFFFFF')

import os, sys
from PIL import Image

def main():
	path = sys.argv[1].strip("'")
	width = int(sys.argv[2].strip("'"))
	height = int(sys.argv[3].strip("'"))
	data = sys.argv[4].strip("'")
	colorcode = sys.argv[5].strip("'")


	if colorcode == "RGB":
		if(len(data) % 7 != 0):
			print('Wrong image data format', file=sys.stderr)
			sys.exit(1)

		result = []
		for i in range(0, len(data), 7):
			result.append((int(data[i+1:i+3], 16), int(data[i+3:i+5], 16), int(data[i+5:i+7], 16)))
	else:
		if(len(data) % 9 != 0):
			print('Wrong image data format', file=sys.stderr)
			sys.exit(1)

		result = []
		for i in range(0, len(data), 9):
			result.append((int(data[i+1:i+3], 16), int(data[i+3:i+5], 16), int(data[i+5:i+7], 16), int(data[i+7:i+9], 16)))

	try:
		img = Image.new(colorcode, (width, height))
		img.putdata(result)
		os.makedirs(os.path.dirname(path), exist_ok=True)
		img.save(path)
	except Exception as e:
		print(e, file=sys.stderr)
		sys.exit(1)

if __name__ == "__main__":
	if(len(sys.argv) != 6):
		print(f'Wrong argument amount: {len(sys.argv)}, {sys.argv}', file=sys.stderr)
		sys.exit(1)
	main()
