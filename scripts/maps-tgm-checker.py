import argparse, sys
from os import sep, path, walk

def main():
	opt = argparse.ArgumentParser()
	opt.add_argument('dir', help='The directory to recursively scan for *.dmm files with invalid format')
	args = opt.parse_args()

	if not path.isdir(args.dir):
		print('Not a directory')
		sys.exit(1)

	bad_map_files = []

	for root, subdirs, files in walk(args.dir):
		for filename in files:
			if filename.endswith('.dmm'):
				file_path = path.join(root, filename)
				with open(file_path, 'r') as file:
					first_line = file.readline()
					if not first_line.startswith('//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE'):
						bad_map_files.append(file_path)
	
	if len(bad_map_files) > 0:
		print('Bad map files (not TGM):')
		print(*bad_map_files, sep='\n')
		sys.exit(1)

if __name__ == '__main__':
	main()
