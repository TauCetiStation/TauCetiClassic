# note: dmm pre-commit hook or sdmm should be as last step after converts

import sys, re, io
import fnmatch
from os import path, walk

def main():
	map_list = ["delta.dmm", "prometheus.dmm", "boxstation.dmm", "falcon.dmm", "gamma.dmm", "stroechka.dmm", "asteroid.dmm"]

	for root, subdirs, files in walk("maps/"):
		for filename in files:
			#if (filename in map_list):
			#if (filename == "boxstation.dmm"):
			if fnmatch.fnmatch(filename, "*.dmm"):
				file_path = path.join(root, filename)
				print(file_path)
				with open(file_path, 'r') as file :
					mapfile = file.read()

				### doulbe turfs first
				# wood siding
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding1"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 1\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding2"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding3"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 1\n\t}\n,/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding4"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 4\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding5"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 5\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding6"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 6\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding6"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 6\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding7"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy_end";\n\tdir = 4\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding8"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 8\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding9"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 9\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding10"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 10\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding11"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy_end";\n\tdir = 8\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding12"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 4\n\t}\n,/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy";\n\tdir = 8\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding13"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy_end";\n\tdir = 1\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding14"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy_end";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "wood_siding15"\s+}', 
					r'/obj/effect/decal/turf_decal/wood{\n\ticon_state = "spline_fancy_full"\n\t}', mapfile)

				# siding
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding1"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 1\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding2"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 2\n\t}', mapfile)
				#mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding3"\s+}', 
				#	r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 1\n\t}\n,/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding4"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 4\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding5"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 5\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding6"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 6\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding6"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 6\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding7"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain_end";\n\tdir = 4\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding8"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 8\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding9"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 9\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding10"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 10\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding11"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain_end";\n\tdir = 8\n\t}', mapfile)
				#mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding12"\s+}', 
				#	r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 4\n\t}\n,/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 8\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding13"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain_end";\n\tdir = 1\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding14"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain_end";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding15"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain_full"\n\t}', mapfile)

				mapfile = re.sub(r'/turf/simulated/floor/holofloor{\s+(dir = [0-9]*;\n\t)?icon_state = "siding1"\s+}', 
					r'/obj/effect/decal/turf_decal/metal{\n\ticon_state = "spline_plain";\n\tdir = 1\n\t}', mapfile)

				# warninglines
				mapfile = re.sub(r'/turf/simulated/floor([/0-9a-zA-Z_-]*)?{\s+(dir = [0-9]*;\n\t)?icon_state = "warningline"\s+}', 
					r'/obj/effect/decal/turf_decal{\n\t\2icon_state = "warn"\n\t}', mapfile)

				# warninglinecorners
				mapfile = re.sub(r'/turf/simulated/floor([/0-9a-zA-Z_-]*)?{\s+icon_state = "warninglinecorners"\s+}', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "warn_corner";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor([/0-9a-zA-Z_-]*)?{\s+dir = 2;\n\ticon_state = "warninglinecorners"\s+}', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "warn_corner";\n\tdir = 2\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor([/0-9a-zA-Z_-]*)?{\s+dir = 1;\n\ticon_state = "warninglinecorners"\s+}', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "warn_corner";\n\tdir = 8\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor([/0-9a-zA-Z_-]*)?{\s+dir = 4;\n\ticon_state = "warninglinecorners"\s+}', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "warn_corner";\n\tdir = 1\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor([/0-9a-zA-Z_-]*)?{\s+dir = 8;\n\ticon_state = "warninglinecorners"\s+}', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "warn_corner";\n\tdir = 4\n\t}', mapfile)

				## single turfs with decals next
				# chapel mosaic
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [1,2,4,8];\n\t)?icon_state = "chapel"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "mosaic_1"\n\t},\n/turf/simulated/floor{\n\tdir = 5;\n\ticon_state = "vault"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+dir = 5;\n\ticon_state = "chapel"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\tdir = 4;\n\ticon_state = "mosaic_2"\n\t},\n/turf/unsimulated/floor{\n\tdir = 5;\n\ticon_state = "vault"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+dir = 6;\n\ticon_state = "chapel"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\tdir = 2;\n\ticon_state = "mosaic_2"\n\t},\n/turf/unsimulated/floor{\n\tdir = 5;\n\ticon_state = "vault"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = 9;\n\t)?icon_state = "chapel"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\tdir = 1;\n\ticon_state = "mosaic_2"\n\t},\n/turf/unsimulated/floor{\n\tdir = 5;\n\ticon_state = "vault"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = 10;\n\t)?icon_state = "chapel"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\tdir = 8;\n\ticon_state = "mosaic_2"\n\t},\n/turf/unsimulated/floor{\n\tdir = 5;\n\ticon_state = "vault"\n\t}', mapfile)

				# bot square
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "bot"\s+}', 
						r'/obj/effect/decal/turf_decal/alpha/yellow{\n\ticon_state = "bot"\n\t},\n/turf/simulated/floor', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "bot"\s+}', 
						r'/obj/effect/decal/turf_decal/alpha/yellow{\n\ticon_state = "bot"\n\t},\n/turf/unsimulated/floor', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "bot"\s+}', 
						r'/obj/effect/decal/turf_decal/alpha/yellow{\n\ticon_state = "bot"\n\t},\n/turf/simulated/floor/plating/airless', mapfile)

				# delivery square
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "delivery"\s+}', 
						r'/obj/effect/decal/turf_decal/alpha/yellow{\n\ticon_state = "delivery"\n\t},\n/turf/simulated/floor', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "delivery"\s+}', 
						r'/obj/effect/decal/turf_decal/alpha/yellow{\n\ticon_state = "delivery"\n\t},\n/turf/unsimulated/floor', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "delivery";\n\ttemperature = 393.15\s+}', 
						r'/obj/effect/decal/turf_decal/alpha/yellow{\n\ticon_state = "delivery"\n\t},\n/turf/simulated/floor{\n\ttemperature = 393.15\n\t}', mapfile)

				# asteroidwarning
				mapfile = re.sub(r'/turf/simulated/floor/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "asteroidwarning"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "ast_warn"\n\t},\n/turf/simulated/floor/airless{\n\ticon_state = "asteroidfloor"\n\t}', mapfile)

				# warning
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warning"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warning"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/unsimulated/floor', mapfile)

				# warningcorner
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warningcorner"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warningcorner"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/unsimulated/floor', mapfile)

				# warnplate
				mapfile = re.sub(r'/turf/simulated/floor/plating{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplate"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor/plating', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplate"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor/plating/airless', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplate"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/unsimulated/floor', mapfile)

				mapfile = re.sub(r'/turf/simulated/floor/plating{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplate";\n\tnitrogen = 0.01;\n\toxygen = 0.01\s+}',
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor/plating', mapfile) # lolwut

				# warnplatecorner
				mapfile = re.sub(r'/turf/simulated/floor/plating{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplatecorner"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor/plating', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplatecorner"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor/plating/airless', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warnplatecorner"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/unsimulated/floor', mapfile)

				# warnwhite
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warnwhite"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor{\n\ticon_state = "white"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warnwhite"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "white"\n\t}', mapfile)

				# warnwhitecorner
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warnwhitecorner"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor{\n\ticon_state = "white"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warnwhitecorner"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "white"\n\t}', mapfile)

				# floorgrimecaution
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "floorgrimecaution"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor{\n\ticon_state = "floorgrime"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "floorgrimecaution"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "floorgrime"\n\t}', mapfile)

				# podhatch
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatch"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor{\n\ticon_state = "podhatchfull"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatch"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "podhatchfull"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/shuttle/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatch"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/shuttle/floor{\n\ticon_state = "podhatchfull"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatch"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor/plating/airless{\n\ticon_state = "podhatchfull"\n\t}', mapfile)

				# podhatchcorner
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatchcorner"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor{\n\ticon_state = "podhatchfull"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatchcorner"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "podhatchfull"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/shuttle/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatchcorner"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/shuttle/floor{\n\ticon_state = "podhatchfull"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "podhatchcorner"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor/plating/airless{\n\ticon_state = "podhatchfull"\n\t}', mapfile)

				# warndark
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warndark"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/simulated/floor{\n\ticon_state = "dark"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warndark"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "dark"\n\t}', mapfile)

				# warndarkcorners
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warndarkcorners"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/simulated/floor{\n\ticon_state = "dark"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "warndarkcorners"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\t\1icon_state = "warn_corner"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "dark"\n\t}', mapfile)

				# loadingarea
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "loadingarea"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "loadingarea"\n\t},\n/obj/effect/decal/turf_decal/alpha/black{\n\t\1icon_state = "arrow"\n\t},\n/turf/simulated/floor', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "loadingarea"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "loadingarea"\n\t},\n/obj/effect/decal/turf_decal/alpha/black{\n\t\1icon_state = "arrow"\n\t},\n/turf/unsimulated/floor', mapfile)

				# loadingareadirty1 (removed)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "loadingareadirty1"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "loadingarea"\n\t},\n/obj/effect/decal/turf_decal/alpha/black{\n\t\1icon_state = "arrow"\n\t},\n/turf/simulated/floor{\n\ticon_state = "floorgrime"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "loadingareadirty1"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "loadingarea"\n\t},\n/obj/effect/decal/turf_decal/alpha/black{\n\t\1icon_state = "arrow"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "floorgrime"\n\t}', mapfile)

				# loadingareadirty2 (removed)
				mapfile = re.sub(r'/turf/simulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "loadingareadirty2"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "loadingarea"\n\t},\n/obj/effect/decal/turf_decal/alpha/black{\n\t\1icon_state = "arrow"\n\t},\n/turf/simulated/floor{\n\ticon_state = "floorgrime"\n\t}', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "loadingareadirty2"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "loadingarea"\n\t},\n/obj/effect/decal/turf_decal/alpha/black{\n\t\1icon_state = "arrow"\n\t},\n/turf/unsimulated/floor{\n\ticon_state = "floorgrime"\n\t}', mapfile)

				# platebot
				mapfile = re.sub(r'/turf/simulated/floor/plating{\s+(dir = [0-9]*;\n\t)?icon_state = "platebot"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "bot"\n\t},\n/turf/simulated/floor/plating', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "platebot"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "bot"\n\t},\n/turf/simulated/floor/plating/airless', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "platebot"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "bot"\n\t},\n/turf/unsimulated/floor', mapfile)

				mapfile = re.sub(r'/turf/simulated/floor/plating{\s+(dir = [0-9]*;\n\t)?icon_state = "platebot";\n\tnitrogen = 0.01;\n\toxygen = 0.01\s+}',
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "bot"\n\t},\n/turf/simulated/floor/plating', mapfile) # lolwut
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "platebot";\n\tname = "plating"\s+}',
				r'/obj/effect/decal/turf_decal/alpha/yellow{\n\t\1icon_state = "bot"\n\t},\n/turf/unsimulated/floor', mapfile) # lolwut2

				# platebotc
				mapfile = re.sub(r'/turf/simulated/floor/plating{\s+(dir = [0-9]*;\n\t)?icon_state = "platebotc"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/cyan{\n\t\1icon_state = "bot"\n\t},\n/turf/simulated/floor/plating', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/plating/airless{\s+(dir = [0-9]*;\n\t)?icon_state = "platebotc"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/cyan{\n\t\1icon_state = "bot"\n\t},\n/turf/simulated/floor/plating/airless', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+(dir = [0-9]*;\n\t)?icon_state = "platebotc"\s+}', 
				r'/obj/effect/decal/turf_decal/alpha/cyan{\n\t\1icon_state = "bot"\n\t},\n/turf/unsimulated/floor', mapfile)

				## plates
				# space station 13 (not on the maps)

				# derelict
				mapfile = re.sub(r'/turf/simulated/floor/airless{\s+icon_state = "derelict([0-9]*)"\s+}', 
				r'/obj/effect/decal/turf_decal{\n\ticon_state = "derelict_\1"\n\t},\n/turf/simulated/floor/airless', mapfile)

				# exodus
				mapfile = re.sub(r'/turf/simulated/floor/exodus{\s+icon_state = "R([0-9]*)"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\ticon_state = "exodus_\1"\n\t},\n/turf/simulated/floor', mapfile)

				mapfile = re.sub(r'/turf/simulated/floor/exodus', 
						r'/turf/simulated/floor', mapfile) # also need to cleanup this random type

				# velocity
				mapfile = re.sub(r'/turf/unsimulated/floor/velocity{\s+icon_state = "vel_(0)?([0-9]*)"\s+}', 
						r'/obj/effect/decal/turf_decal{\n\ticon_state = "velocity_\2"\n\t},\n/turf/unsimulated/floor', mapfile)

				mapfile = re.sub(r'/turf/unsimulated/floor/velocity', 
						r'/turf/unsimulated/floor', mapfile) # also need to cleanup this random type


				# plaque
				mapfile = re.sub(r'/turf/simulated/floor/goonplaque', 
					r'/obj/effect/decal/turf_decal/goonplaque,\n/turf/simulated/floor', mapfile)

				# /turf/simulated/floor/mech_bay_recharge_floor/airless
				mapfile = re.sub(r'/turf/simulated/floor/mech_bay_recharge_floor/airless', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "recharge_floor_asteroid"\n\t},\n/turf/simulated/floor/airless{\n\ticon_state = "asteroidfloor"\n\t}', mapfile)

				# /turf/simulated/floor/mech_bay_recharge_floor
				mapfile = re.sub(r'/turf/simulated/floor/mech_bay_recharge_floor', 
					r'/obj/effect/decal/turf_decal{\n\ticon_state = "recharge_floor"\n\t},\n/turf/simulated/floor', mapfile)

				### final cleanup
				# floorgrime -> tile + dirt;
				mapfile = re.sub(r'/turf/simulated/floor{\s+icon_state = "floorgrime"\s+}', 
					r'/obj/effect/decal/cleanable/dirt,\n/turf/simulated/floor', mapfile)
				mapfile = re.sub(r'/turf/simulated/floor/airless{\s+icon_state = "floorgrime"\s+}', 
					r'/obj/effect/decal/cleanable/dirt,\n/turf/simulated/floor/airless', mapfile)
				mapfile = re.sub(r'/turf/unsimulated/floor{\s+icon_state = "floorgrime"\s+}', 
					r'/obj/effect/decal/cleanable/dirt,\n/turf/unsimulated/floor', mapfile)

				## error state
				# removed, only one used from all set
				mapfile = re.sub(r'whiteblue_ex', 
					r'whiteblue', mapfile)

				with open(file_path, 'w') as file :
					file.write(mapfile)

if __name__ == '__main__':
	main()
