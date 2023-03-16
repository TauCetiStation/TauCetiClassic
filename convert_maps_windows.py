# please don't look
# one time govnokode script, i don't want to see it ever again

# note: dmm pre-commit hook or sdmm should be as last step after converts

import sys, re, io
import fnmatch
from os import path, walk

def main():

	for root, subdirs, files in walk("maps/"):
		for filename in files:
			if fnmatch.fnmatch(filename, "*.dmm"):
			#if filename == "prometheus.dmm":
				file_path = path.join(root, filename)
				print(file_path)
				with open(file_path, 'r') as file :
					mapfile = file.read()

				# first pass - fulltiles (easy mode)
				mapfile = re.sub(r'/obj/structure/window/reinforced{\s+dir = ([596]|10)\s+}', '/obj/structure/window/fulltile/reinforced', mapfile)
				mapfile = re.sub(r'/obj/structure/window{\s+dir = ([596]|10)\s+}', '/obj/structure/window/fulltile', mapfile)
				mapfile = re.sub(r'/obj/structure/window/phoronreinforced{\s+dir = ([596]|10)\s+}', '/obj/structure/window/fulltile/reinforced/phoron', mapfile)
				mapfile = re.sub(r'/obj/structure/window/reinforced/tinted{\s+dir = ([596]|10)\s+}', '/obj/structure/window/fulltile/reinforced/tinted', mapfile)

				mapfile = re.sub(r'/obj/structure/window/reinforced/indestructible{\s+dir = ([596]|10)\s+}', '/obj/structure/window/fulltile/reinforced/indestructible', mapfile)
				mapfile = re.sub(r'/obj/structure/window/reinforced/indestructible{\n\tdir = 5;\n\tlayer = 3.4\n\t}', '/obj/structure/window/fulltile/reinforced/indestructible', mapfile) # ty unknown mapper

				mapfile = re.sub(r'/obj/structure/window/basic{\s+dir = ([596]|10)\s+}', '/obj/structure/window/fulltile', mapfile)

				# prepare for more easy line by line read
				mapfile = re.sub(r'\)(\n\"|\n\n)', r'\n)\1', mapfile) # fuck lists

				output = ""
				flag_batch_grille = 0
				flag_batch_fulltile = 0
				batch = 0
				mapfile_lines = io.StringIO(mapfile)

				flag_batch_smalltile_reinforced = 0
				flag_batch_smalltile_reinforced_phoron = 0
				flag_batch_smalltile_reinforced_tinted = 0
				flag_batch_smalltile_reinforced_polarized = 0
				#flag_batch_smalltile = 0

				# second pass - fix grille under fw
				# and third pass - replace combined windows with fulltiles (somehow)
				for line in mapfile_lines:
					if(batch):
						if line == ")\n": # tile ended, drop it now and clean flags

							# grille replace for fulltiles from first pass
							if flag_batch_fulltile and flag_batch_grille:
								batch = re.sub(r'(/obj/structure/window/fulltile(/reinforced/phoron|/reinforced/tinted|/reinforced/indestructible|/reinforced)?)', r'\1{\n\tgrilled = 1\n}', batch) # sdmm/driver will fix format later
								batch = re.sub(r'(/obj/structure/grille({\s+.*\s+})?(,)?\n?)', '', batch)

							# multiobj window -> fulltiles
							if(flag_batch_smalltile_reinforced > 1 and flag_batch_grille):
								batch = re.sub(r'/obj/structure/window/reinforced(?!/)({\s+.*\s+})?(,)?\n?', '', batch)

								if(not flag_batch_fulltile): # we already have one, shame on mappers. so just clean thin windows and nothing more
									if(flag_batch_grille):
										batch = re.sub(r'/obj/structure/grille({\s+.*\s+})?(,)?\n?', '', batch)
										batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced{\n\tgrilled = 1\n}\n"
									else:
										batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced\n"

							# multiobj phoron window -> phoron fulltiles
							if(flag_batch_smalltile_reinforced_phoron > 1 and flag_batch_grille):
								batch = re.sub(r'/obj/structure/window/phoronreinforced(?!/)({\s+.*\s+})?(,)?\n?', '', batch)

								if(flag_batch_grille):
									batch = re.sub(r'/obj/structure/grille({\s+.*\s+})?(,)?\n?', '', batch)
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced/phoron{\n\tgrilled = 1\n}\n"
								else:
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced/phoron\n"

							# multiobj tinted window -> tinted fulltiles
							if(flag_batch_smalltile_reinforced_tinted > 1 and flag_batch_grille):
								batch = re.sub(r'/obj/structure/window/reinforced/tinted(?!/)({\s+.*\s+})?(,)?\n?', '', batch)

								if(flag_batch_grille):
									batch = re.sub(r'/obj/structure/grille({\s+.*\s+})?(,)?\n?', '', batch)
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced/tinted{\n\tgrilled = 1\n}\n"
								else:
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced/tinted\n"

							# multiobj polarised window -> polarised fulltiles
							# they have id code we need to handle
							if(flag_batch_smalltile_reinforced_polarized > 1 and flag_batch_grille):

								if matchcode := re.search(r'/obj/structure/window/reinforced/polarized{[\s\w\n=;,]*id = \"(\S*)\"[\s\w\n=;,]*}', batch):
									idcode = matchcode.group(1)

								if idcode:
									batch = re.sub(r'/obj/structure/grille({\s+.*\s+})?(,)?\n?', '', batch)
									batch = re.sub(r'/obj/structure/window/reinforced/polarized(?!/)({[\sa-zA-Z0-9=;\" ]*})?(,)?\n?', '', batch)
									batch = re.sub(r'/obj/structure/window/fulltile/reinforced(?!/)({[\sa-zA-Z0-9=;\" ]*})?(,)?\n?', '', batch) # priority to polarised fulltile
									batch = batch[:-1] + ",\n/obj/structure/window/fulltile/reinforced/polarized{{\n\tgrilled = 1;\n\tid = \"{}\"\n}}\n".format(idcode)

							output += batch
							output += line
							batch = 0
							flag_batch_grille = 0
							flag_batch_fulltile = 0
							flag_batch_smalltile_reinforced = 0
							flag_batch_smalltile_reinforced_phoron = 0
							flag_batch_smalltile_reinforced_tinted = 0
							flag_batch_smalltile_reinforced_polarized = 0
						else:
							if(line.find("/obj/structure/grille")) != -1:
								flag_batch_grille = 1
							if(re.search(r'/obj/structure/window/fulltile(?!/)', line)):
								flag_batch_fulltile = 1
							if(re.search(r'/obj/structure/window/fulltile/reinforced(?!/)', line)):
								flag_batch_fulltile = 1
							if(re.search(r'/obj/structure/window/fulltile/reinforced/phoron(?!/)', line)):
								flag_batch_fulltile = 1
							if(re.search(r'/obj/structure/window/fulltile/reinforced/tinted(?!/)', line)):
								flag_batch_fulltile = 1
							if(re.search(r'/obj/structure/window/fulltile/reinforced/indestructible(?!/)', line)):
								flag_batch_fulltile = 1
							if(re.search(r'/obj/structure/window/reinforced(?!/)', line)):
								flag_batch_smalltile_reinforced += 1
							#if(line.find("/obj/structure/window{")) != -1: # we don't have them
							#	flag_batch_smalltile = 1
							if(re.search(r'/obj/structure/window/phoronreinforced(?!/)', line)):
								flag_batch_smalltile_reinforced_phoron += 1

							# tinted
							if(re.search(r'/obj/structure/window/reinforced/tinted(?!/)', line)):
								flag_batch_smalltile_reinforced_tinted += 1

							# polarised (no)
							if(re.search(r'/obj/structure/window/reinforced/polarized(?!/)', line)):
								flag_batch_smalltile_reinforced_polarized += 1

							batch += line

					else:
						if line.find("= (") != -1:
							batch = line # start reading in tile batch
						else:
							output += line

				# fourth and last pass - fix paths for all old /window to /window/thin
				# ...
				output = re.sub(r'/obj/structure/window/reinforced(?!/)', '/obj/structure/window/thin/reinforced', output)
				output = re.sub(r'/obj/structure/window/phoronreinforced(?!/)', '/obj/structure/window/thin/reinforced/phoron', output)
				output = re.sub(r'/obj/structure/window/reinforced/tinted(?!/)', '/obj/structure/window/thin/reinforced/tinted', output)
				#output = re.sub(r'/obj/structure/window(?!/full|/thin)', r'/obj/structure/window/thin/1', output)
				output = re.sub(r'/obj/structure/window/basic(?!/)', '/obj/structure/window/thin', output)
				
				output = re.sub(r'/obj/structure/window/reinforced/holowindow(?!/)', '/obj/structure/window/thin/reinforced/holowindow', output)
				output = re.sub(r'/obj/structure/window/reinforced/holowindow/disappearing(?!/)', '/obj/structure/window/thin/reinforced/holowindow/disappearing', output)

				output = re.sub(r'/obj/structure/window/reinforced/shuttle', '/obj/structure/window/shuttle/reinforced', output)

				# okay, we need to fix it back...
				output = re.sub(r'\n\)(\n\"|\n\n)', r')\1', output)

				with open(file_path, 'w') as file :
					file.write(output)

if __name__ == '__main__':
	main()
