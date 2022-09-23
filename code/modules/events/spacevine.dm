/datum/event/spacevine

/datum/event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	for(var/areapath in typesof(/area/station/hallway))
		var/area/A = locate(areapath)
		for(var/turf/simulated/floor/F in A.contents)
			if(!is_blocked_turf(F))
				turfs += F

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/simulated/floor/T = pick(turfs)
		if(prob(50))
			var/atom/A = new/obj/effect/spacevine_controller(T) //spawn a controller at turf
			announce_to_ghosts("Event Spacevines", A)
			message_admins("<span class='notice'>Event: Spacevines spawned at [T.loc] [COORD(T)] [ADMIN_JMP(T)]</span>")
		else
			var/atom/A = new/obj/effect/biomass_controller(T) //spawn a controller at turf
			announce_to_ghosts("Event Biomass", A)
			message_admins("<span class='notice'>Event: Biomass spawned at [T.loc] [COORD(T)] [ADMIN_JMP(T)]</span>")
