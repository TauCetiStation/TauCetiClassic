//Helper Modules

/datum/map_generator_module/bottom_layer/massdelete
	spawnableAtoms = list()
	spawnableTurfs = list()
	var/deleteturfs = TRUE //separate var for the empty type.

/datum/map_generator_module/bottom_layer/massdelete/generate()
	if(!mother)
		return
	for(var/V in mother.map)
		var/turf/T = V
		T.empty(deleteturfs ? null : T.type)

//Only places atoms/turfs on area borders
/datum/map_generator_module/border
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/map_generator_module/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/map_generator_module/border/proc/is_border(turf/T)
	for(var/direction in global.cardinal)
		if (get_step(T, direction) in mother.map)
			continue
		return 1
	return 0

/datum/map_generator/massdelete
	modules = list(/datum/map_generator_module/bottom_layer/massdelete)
	buildmode_name = "Block: Full Mass Deletion"
