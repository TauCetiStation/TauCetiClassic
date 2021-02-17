//for all window/New and door/window/New
/proc/color_windows(area = "common")
	var/static/wcCommon
	if(!wcCommon)
		wcCommon = pick(list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#cc99ff", "#ff6600", "#3399ff", "#969696", "#ffffff"))
	return wcCommon

/proc/painting_objects(list/possible_areas, color)
	for(var/type in possible_areas)
		for(var/obj/structure/window/W in get_area_by_type(type))
			W.color = color
		for(var/obj/machinery/door/window/D in get_area_by_type(type))
			D.color = color

//replaces color in some area
/proc/color_windows_init()
	//RED (Only sec stuff honestly)
	var/list/red = list("#aa0808", "#990707", "#e50909", "#e50909")
	//BAR
	var/list/bar = list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#3399ff", "#00ffff", "#ff6600", "#ffffff")
	//DWARFS
	var/list/dw = list("#993300", "#ff6600", "#ffcc00", "#ff9933")
	//PURPLE (RnD + Research outpost)
	var/list/purple = list("#ba62b1", "#ba3fad", "#a54f9e", "#b549d1")
	//BROWN (Mining + Cargo)
	var/list/brown = list("#9e5312", "#99761e", "#a56b00", "#d87f2b")
	//GREEN (Virology and Hydro areas)
	var/list/green = list("#aed18b", "#7bce23", "#5a9619", "#709348")
	//BLUE (Some of Medbay areas)
	var/list/blue = list("#054166", "#5995ba", "#1e719e", "#7cb8dd")

	var/list/color_by_types = list(
		pick(red)    = typesof(/area/station/security),
		pick(purple) = typesof(/area/station/rnd) + typesof(/area/asteroid/research_outpost) + /area/station/medical/genetics,
		pick(brown)  = typesof(/area/station/cargo) + typesof(/area/asteroid/mine),
		pick(green)  = list(/area/station/medical/virology,
							/area/station/civilian/hydroponics,
							/area/asteroid/research_outpost/maintstore1,
							/area/asteroid/research_outpost/sample),
		pick(blue)   = typesof(/area/station/medical),
		pick(bar)    = list(/area/station/civilian/bar),
		pick(dw)     = list(/area/asteroid/mine/dwarf),
		COLOR_WHITE  = typesof(/area/shuttle),
	)

	for(var/color in color_by_types)
		painting_objects(color_by_types[color], color)
