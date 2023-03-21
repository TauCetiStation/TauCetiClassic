SUBSYSTEM_DEF(station_coloring)
	name = "Station Coloring"
	init_order = SS_INIT_DEFAULT // before SSicon_smooth
	flags = SS_NO_FIRE
	msg_lobby = "Раскрашиваем станцию..."

/datum/controller/subsystem/station_coloring/Initialize()

	//RED (Only sec stuff honestly)
	var/list/red = list("#855363", "#7d5263", "#a35364", "#520014")
	//BAR
	var/list/bar = list("#3790aa", "#5ca9c1", "#5cb092", "#78baac", "#4a9bdf", "#30cedf", "#b0825f", "#b0cedf")
	//DWARFS
	var/list/dw = list("#7d685f", "#b0825f", "#b0b55f", "#b09b79")
	//PURPLE (RnD + Research outpost)
	var/list/purple = list("#8d80b8", "#8d6eb6", "#8376ae", "#8b73c8")
	//BROWN (Mining + Cargo)
	var/list/brown = list("#7f7868", "#7d8a6e", "#83845f", "#9c8e75")
	//GREEN (Virology and Hydro areas)
	var/list/green = list("#87b7a5", "#6eb671", "#5d9a6c", "#689883")
	//BLUE (Some of Medbay areas)
	var/list/blue = list("#336f92", "#5d99bc", "#3f87ae", "#6eabce", "#054166")

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
		for(var/obj/structure/window/W in get_area_by_type(type)) // for in area is slow by refs, but we have a time while in lobby so just to-do-sometime
			W.change_color(color)
		for(var/obj/machinery/door/window/D in get_area_by_type(type))
			D.color = color

/datum/controller/subsystem/station_coloring/proc/get_default_color()
	var/static/default_color = pick(list("#1a356e", "#361a6e", "#164f41"))

	return default_color
