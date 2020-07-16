/datum/event/spacevine

/datum/event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/spacevine/SV = new()

	for(var/area/A in typesof(/area/station/hallway))
		for(var/turf/simulated/floor/F in A.contents)
			if(!F.Enter(SV))
				turfs += F

	qdel(SV)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/simulated/floor/T = pick(turfs)
		if(prob(50))
			new/obj/effect/spacevine_controller(T) //spawn a controller at turf
			message_admins("<span class='notice'>Event: Spacevines spawned at [T.loc] ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]</span>")
		else
			new/obj/effect/biomass_controller(T) //spawn a controller at turf
			message_admins("<span class='notice'>Event: Biomass spawned at [T.loc] ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]</span>")
