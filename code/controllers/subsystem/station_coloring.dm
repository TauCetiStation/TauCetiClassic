SUBSYSTEM_DEF(station_coloring)
	name = "Station Coloring"
	init_order = SS_INIT_DEFAULT // before SSicon_smooth
	flags = SS_NO_FIRE
	msg_lobby = "Раскрашиваем станцию..."

/datum/controller/subsystem/station_coloring/Initialize()

	//RED (Only sec stuff honestly)
	var/list/red = list("#d0294c", "#d6292f", "#d62f29", "#d63a29")
	//BAR
	var/list/bar = list("#3790aa", "#5ca9c1", "#5cb092", "#4daf9b", "#4a9bdf", "#30cedf", "#c7804a", "#b0cedf")
	//DWARFS
	var/list/dw = list("#7d685f", "#b0825f", "#b0b55f", "#b09b79")
	//PURPLE (RnD + Research outpost)
	var/list/purple = list("#674dba", "#6b43bc", "#864ec5", "#8d40c3")
	//BROWN (Mining + Cargo)
	var/list/brown = list("#826627", "#825327", "#a9682b", "#a9542b")
	//GREEN (Virology and Hydro areas)
	var/list/green = list("#50b47c", "#59b25d", "#46955a", "#4ba17b")
	//BLUE (Some of Medbay areas)
	var/list/blue = list("#336f92", "#5d99bc", "#3f87ae", "#6eabce", "#307199")

	var/list/color_palette = list(
		pick(red)          = typesof(/area/station/security),
		pick(purple)       = typesof(/area/station/rnd) + typesof(/area/asteroid/research_outpost) + /area/station/medical/genetics,
		pick(brown)        = typesof(/area/station/cargo) + typesof(/area/asteroid/mine),
		pick(green)        = list(/area/station/medical/virology,
		                        /area/station/civilian/hydroponics,
		                        /area/asteroid/research_outpost/maintstore1,
		                        /area/asteroid/research_outpost/sample),
		pick(blue)         = typesof(/area/station/medical),
		pick(bar)          = list(/area/station/civilian/bar),
		pick(dw)           = list(/area/asteroid/mine/dwarf),
		COLOR_WHITE        = typesof(/area/shuttle),
		COLOR_WHITE        = typesof(/area/centcom),
		COLOR_DARK_GRAY    = typesof(/area/velocity)
	)

	for(var/color in color_palette)
		color_area_objects(color_palette[color], color)

	return ..()

/datum/controller/subsystem/station_coloring/proc/color_area_objects(list/possible_areas, color) // paint in areas
	for(var/type in possible_areas)
		for(var/obj/structure/window/W in get_area_by_type(type)) //for in area is slow by refs, but we have a time while in lobby so just to-do-sometime
			if(W.color) // has already been set by mapper
				continue
			W.change_color(color)
		for(var/obj/machinery/door/window/D in get_area_by_type(type))
			if(D.color)
				continue
			D.color = color

/datum/controller/subsystem/station_coloring/proc/get_default_color()
	var/static/default_color = pick(list("#3c5da5", "#63489e", "#4495bc"))

	return default_color
