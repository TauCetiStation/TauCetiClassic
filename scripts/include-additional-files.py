import argparse, sys, re
from os import sep, path, walk

def main():
	opt = argparse.ArgumentParser()
	opt.add_argument('dir', help='Dir to parse to include specific files')
	opt.add_argument('pattern', help='Pattern used to include files')
	args = opt.parse_args()

	if not path.isdir(args.dir):
		print('Not a directory')
		sys.exit(1)

	file = open('additional_files.dm', 'a')
	pattern = re.compile(args.pattern)

	for root, subdirs, files in walk(args.dir):
		for filename in files:
			if pattern.match(filename):
				file_path = path.join(root, filename).replace('/', '\\')
				file.write('#include "' + file_path + '"\n')

	file.close()

if __name__ == '__main__':
	main()
