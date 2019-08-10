import argparse, re, sys
from os import sep, path, walk

known_volume_channels = [
	"VOL_MUSIC",
	"VOL_AMBIENT",
	"VOL_EFFECTS_MASTER",
	"VOL_EFFECTS_VOICE_ANNOUNCEMENT",
	"VOL_EFFECTS_MISC",
	"VOL_EFFECTS_INSTRUMENT",
	"VOL_NOTIFICATIONS",
	"VOL_ADMIN",
	"VOL_JUKEBOX"
	]

skip_file_path = "./code/game/sound.dm"

def get_bad_playsounds_in_line(line):
	bad_playsounds = []
	result = re.search('(?:playsound|playsound_local)\(([^,]+),(.pick\(.*?\)|[^,]+),([^,\)]+)', line)
	if(result is None):
		return bad_playsounds
	arg3 = result.group(3).strip()
	if(arg3 not in known_volume_channels):
		bad_playsounds.append(result.group(0))
	return bad_playsounds

def get_bad_args_lines_in_file(file):
	bad_lines = {}
	for line_number, line in enumerate(file, 1):
		bad_playsounds = get_bad_playsounds_in_line(line)
		if len(bad_playsounds):
			bad_lines[line_number] = bad_playsounds
	return bad_lines

def print_bad_playsounds(bad_playsounds_by_path):
	for path, bad_playsounds_by_line in bad_playsounds_by_path.items():
		print('Path: {0}'.format(path))
		for line, bad_playsounds in bad_playsounds_by_line.items():
			print('\tLine: {0}'.format(line))
			for bad_arg in bad_playsounds:
				print('\t\t{0}'.format(bad_arg))

def main():
	opt = argparse.ArgumentParser()
	opt.add_argument('dir', help='The directory to recursively scan for *.dm and *.dmm files with invalid volume_channel argument in playsound and playsound_local procs')
	args = opt.parse_args()

	if(not path.isdir(args.dir)):
		print('Not a directory')
		sys.exit(1)

	bad_playsounds_by_path = { }
	# This section parses all *.dm and *.dmm files in the given directory, recursively.
	for root, subdirs, files in walk(args.dir):
		for filename in files:
			if filename.endswith('.dm') or filename.endswith('.dmm'):
				file_path = path.join(root, filename)
				if file_path == skip_file_path:
					continue
				with open(file_path, 'rb') as file:
					bad_arg_by_line = get_bad_args_lines_in_file(file)
					if len(bad_arg_by_line) > 0:
						bad_playsounds_by_path[file_path] = bad_arg_by_line

	print_bad_playsounds(bad_playsounds_by_path)
	if len(bad_playsounds_by_path) > 0:
		sys.exit(1)

if __name__ == "__main__":
	main()
