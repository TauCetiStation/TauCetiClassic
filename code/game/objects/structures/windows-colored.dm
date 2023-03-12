//for all window/New and door/window/New
/proc/color_windows(area = "common")
	var/static/wcCommon
	if(!wcCommon)
		wcCommon = pick(list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#cc99ff", "#ff6600", "#3399ff", "#969696", "#ffffff"))
	return wcCommon

/proc/painting_objects(list/possible_areas, color)
	for(var/type in possible_areas)
		for(var/obj/structure/window/W in get_area_by_type(type))
			if(istype(W, /obj/structure/window/fulltile))
				var/obj/structure/window/fulltile/FT = W
				FT.glass_color = color
				if(SSticker.current_state > GAME_STATE_SETTING_UP)
					FT.regenerate_smooth_icon()
			else
				W.color = color
		for(var/obj/machinery/door/window/D in get_area_by_type(type))
			D.color = color

//replaces color in some area
/proc/color_windows_init()
	//RED (Only sec stuff honestly)
	var/list/red = list("#855363", "#7d5263", "#a35364", "#a35364")
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
	var/list/blue = list("#336f92", "#5d99bc", "#3f87ae", "#6eabce")

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

/client/proc/repaint_area_windows()
	set category = "Fun"
	set name = "Repaint area windows"

	if(!check_rights(R_FUN))
		return

	if(SSticker.current_state <= GAME_STATE_SETTING_UP) // todo: need own flag for color_windows_init (subsystem?)
		to_chat(usr, "<span class='warning'>Can't do this before round start</span>")

	var/new_color = input(src, "Please select new colour.", "Windows colour") as color|null

	if(!new_color)
		return

	var/area/A = get_area(usr)
	if(!A)
		return

	painting_objects(list(A), new_color)

	log_admin("[key_name(src)] repainted the windows [new_color] in \the [A]")
	message_admins("[key_name(src)] repainted the windows [new_color] in \the [A]")
