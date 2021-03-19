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
	if(icon_state == "carpetsymbol" && !isnull(R.carpet_dir))
		if(R.carpet_dir == dir)
			return FALSE
		set_dir(R.carpet_dir)
		return TRUE

	else if(R.carpet_type)
		var/ttype = R.carpet_type
		if(ttype == type) // subtypes are important
			return FALSE
		ChangeTurf(R.carpet_type)
		return TRUE
	return FALSE

/obj/structure/stool/bed/chair/pew/atom_religify(datum/religion/R)
	if(!R.pews_icon_state || R.pews_icon_state == pew_icon)
		return FALSE
	pew_icon = R.pews_icon_state
	update_icon()
	return TRUE

/obj/structure/altar_of_gods/atom_religify(datum/religion/R)
	religion = R
	R.altars |= src
	if(R.altar_icon_state != icon_state)
		icon_state = R.altar_icon_state
		update_icon()
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
