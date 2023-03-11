# please don't look
# one time govnokode script, i don't want to see it ever again

import sys, re, io
import fnmatch
from os import path, walk

def main():

	for root, subdirs, files in walk("maps/"):
		for filename in files:
			#if fnmatch.fnmatch(filename, "*.dmm"):
			if filename == "boxstation.dmm":
				file_path = path.join(root, filename)
				print(file_path)
				with open(file_path, 'r') as file :
					mapfile = file.read()

				# first pass - fulltiles (easy mode)
				mapfile = re.sub(r'/obj/structure/window/reinforced{\s+dir = 5\s+}', '/obj/structure/window/fulltile/reinforced', mapfile)
				mapfile = re.sub(r'/obj/structure/window{\s+dir = 5\s+}', '/obj/structure/window/fulltile', mapfile)

				# prepare for more easy line by line read
				mapfile = re.sub(r'\)(\n\"|\n\n)', r'\n)\1', mapfile) # fuck lists



				output = ""
				flag_batch_grille = 0
				flag_batch_fulltile = 0
				batch = 0
				mapfile_lines = io.StringIO(mapfile)

				flag_batch_smalltile_reinforced = 0
				flag_batch_indestructible = 0
				#flag_batch_smalltile = 0

				# second pass - fix grille under fw
				# and third pass - replace combined windows with fulltiles (somehow)
				for line in mapfile_lines:
					if(batch):
						if line == ")\n": # tile ended, drop it now and clean flags

							# grille replace
							if flag_batch_fulltile and flag_batch_grille:
								batch = re.sub(r'(/obj/structure/window/fulltile(/reinforced)?)', r'\1{\ngrilled = 1\n}', batch) # sdmm/driver will fix format later
								batch = re.sub(r'(/obj/structure/grille({\s+.*\s+})?(,)?\n?)', '', batch)

							# multiobj window	
							if(flag_batch_smalltile_reinforced > 1):
								batch = re.sub(r'/obj/structure/window/reinforced({\s+.*\s+})?(,)?\n?', '', batch)
								
								if(flag_batch_grille):
									batch = re.sub(r'/obj/structure/grille({\s+.*\s+})?(,)?\n?', '', batch)
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced{\ngrilled = 1\n}\n"
								else:
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced\n"

							output += batch
							output += line
							batch = 0
							flag_batch_grille = 0
							flag_batch_fulltile = 0
							flag_batch_smalltile_reinforced = 0
						else:
							if(line.find("/obj/structure/grille")) != -1:
								flag_batch_grille = 1
							if(line.find("/obj/structure/window/fulltile")) != -1:
								flag_batch_fulltile = 1
							if(line.find("/obj/structure/window/reinforced{")) != -1:
								flag_batch_smalltile_reinforced += 1
							#if(line.find("/obj/structure/window{")) != -1: # we don't have them
							#	flag_batch_smalltile = 1

							if(line.find("/obj/structure/window/reinforced/indestructible") != -1):
								flag_batch_indestructible = 1 # todo


							batch += line

					else:
						if line.find("= (") != -1:
							batch = line # start reading in tile batch
						else:
							output += line

				# okay, we need to fix it back...
				output = re.sub(r'\n\)(\n\"|\n\n)', r')\1', output)

				with open(file_path, 'w') as file :
					file.write(output)

if __name__ == '__main__':
	main()
