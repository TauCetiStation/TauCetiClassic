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

/datum/map_generator/massdelete
	modules = list(/datum/map_generator_module/bottom_layer/massdelete)
	buildmode_name = "Block: Full Mass Deletion"
