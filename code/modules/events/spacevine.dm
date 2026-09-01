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
			var/obj/effect/spacevine_controller/SC = new(T)
			var/mutable_appearance/vine_overlay = mutable_appearance('icons/effects/spacevines.dmi', "Light1")
			notify_ghosts("Spacevines spawned at [get_area(T)]", source=SC, alert_overlay=vine_overlay, action=NOTIFY_ORBIT, header="Spacevines")
			message_admins("<span class='notice'>Event: Spacevines spawned at [T.loc] [COORD(T)] [ADMIN_JMP(T)]</span>")
		else
			var/obj/effect/biomass_controller/BC = new(T)
			var/mutable_appearance/biomass_overlay = mutable_appearance('icons/obj/biomass.dmi', "stage1")
			notify_ghosts("Spacevines spawned at [get_area(T)]", source=BC, alert_overlay=biomass_overlay, action=NOTIFY_ORBIT, header="Biomass")
			message_admins("<span class='notice'>Event: Biomass spawned at [T.loc] [COORD(T)] [ADMIN_JMP(T)]</span>")
