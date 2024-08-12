// this file stores all atom_religify procs

/atom/proc/atom_religify(datum/religion/R)
	return FALSE

/turf/simulated/wall/atom_religify(datum/religion/R)
	if(!R.wall_types)
		return FALSE
	for(var/ttype in R.wall_types)
		if(ttype == type)
			return FALSE
	ChangeTurf(pick(R.wall_types))
	return TRUE

/turf/simulated/floor/atom_religify(datum/religion/R)
	if(!R.floor_types)
		return FALSE
	for(var/ttype in R.floor_types)
		if(ttype == type)
			return FALSE
	ChangeTurf(pick(R.floor_types))
	return TRUE

/turf/simulated/floor/carpet/atom_religify(datum/religion/R)
	if(religion_tile && !isnull(R.decal))
		clean_turf_decals()
		new /obj/effect/decal/turf_decal(src, R.decal)
		return TRUE

	else if(R.carpet_type)
		var/ttype = R.carpet_type
		if(ttype == type) // subtypes are important
			return FALSE
		ChangeTurf(R.carpet_type)
		return TRUE
	return FALSE

/obj/structure/stool/bed/chair/pew/atom_religify(datum/religion/R)
	if(!R.emblem_icon_state || R.emblem_icon_state == pew_icon)
		return FALSE
	pew_icon = R.emblem_icon_state
	update_icon()
	return TRUE

/obj/structure/stool/bed/chair/lectern/atom_religify(datum/religion/R)
	if(!R.emblem_icon_state || R.emblem_icon_state == icon_state)
		return FALSE
	emblem_overlay.icon_state = R.emblem_icon_state
	lectern_overlay.cut_overlay(emblem_overlay)
	lectern_overlay.add_overlay(emblem_overlay)
	cut_overlay(emblem_overlay)
	add_overlay(emblem_overlay)
	return TRUE

/obj/structure/altar_of_gods/atom_religify(datum/religion/R)
	if(R.altar_icon_state != icon_state)
		icon_state = R.altar_icon_state
		update_icon()

	if(religion != R)
		return FALSE

	religion = R
	R.altars |= src
	return TRUE

/obj/machinery/door/airlock/atom_religify(datum/religion/R)
	if(!R.door_types)
		return FALSE
	for(var/ttype in R.door_types)
		if(ttype == type)
			return FALSE
	var/ttype = pick(R.door_types)
	new ttype(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/mineral_door/atom_religify(datum/religion/R)
	if(!R.door_types)
		return FALSE
	for(var/ttype in R.door_types)
		if(ttype == type)
			return FALSE
	var/ttype = pick(R.door_types)
	new ttype(get_turf(src))
	qdel(src)
	return TRUE
