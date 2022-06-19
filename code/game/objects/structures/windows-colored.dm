/proc/painting_objects(list/possible_areas, color)
	for(var/type in possible_areas)
		for(var/obj/structure/window/W in get_area_by_type(type))
			W.update_color(color)
		for(var/obj/machinery/door/window/D in get_area_by_type(type))
			D.color = color

//replaces color in some area
// you cant change dwarf's color because its fucking useless
/proc/color_windows_init(cred = "", cbar = "", cprl = "", cbrwn = "", cgrn = "", cbl = "")
	//RED (Only sec stuff honestly)
	var/list/red = cred ? cred : list("#ff1200", "#ff002c", "#b9000a")
	//BAR
	var/list/bar = cbar ? cbar : list("#cc5200", "#333333", "#f94279")
	//DWARFS
	var/list/dw = list("#993300", "#ff6600", "#ffcc00", "#ff9933")
	//PURPLE (RnD + Research outpost)
	var/list/purple = cprl ? cprl : list("#530d64", "#800080", "#310062")
	//BROWN (Mining + Cargo)
	var/list/brown = cbrwn ? cbrwn : list("#9e5312", "#b05200", "#bf4000")
	//GREEN (Virology and Hydro areas)
	var/list/green = cgrn ? cgrn : list("#3a551a", "#005000", "#4b5320")
	//BLUE (Some of Medbay areas)
	var/list/blue = cbl ? cbl : list("#0d7952", "#5995ba", "#1e719e")

	var/list/color_by_types = list(
		pick(red)    = typesof(/area/station/security),
		pick(purple) = typesof(/area/station/rnd) + typesof(/area/asteroid/research_outpost) + /area/station/medical/genetics,
		pick(brown)  = typesof(/area/station/cargo) + typesof(/area/asteroid/mine),
		pick(blue)   = typesof(/area/station/medical),
		pick(green)  = list(/area/station/medical/virology,
							/area/station/civilian/hydroponics,
							/area/asteroid/research_outpost/maintstore1,
							/area/asteroid/research_outpost/sample),
		pick(bar)    = list(/area/station/civilian/bar),
		pick(dw)     = list(/area/asteroid/mine/dwarf),
		COLOR_WHITE  = typesof(/area/shuttle),
	)

	for(var/color in color_by_types)
		painting_objects(color_by_types[color], color)
