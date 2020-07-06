/var/global/sent_aliens_to_station = 0

/datum/event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)
	sent_aliens_to_station = 1

/datum/event/alien_infestation/announce()
	if(successSpawn)
		command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", "lifesigns")


/datum/event/alien_infestation/start()
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return

	var/list/candidates = get_larva_candidates()

	while(spawncount > 0 && candidates.len)
		var/obj/vent = pick(vents)
		var/candidate = pick(candidates)

		var/mob/living/carbon/xenomorph/larva/new_xeno = new(vent.loc)
		new_xeno.key = candidate

		candidates -= candidate
		vents -= vent
		spawncount--
		successSpawn = 1


/proc/get_vents()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in machines)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.PARENT1
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmosmch.len > 50)
				vents += temp_vent
	return vents
