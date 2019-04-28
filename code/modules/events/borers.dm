//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

/datum/event/borer_infestation
	oneShot = 1

/datum/event/borer_infestation
	announceWhen = 400

	var/spawncount = 1
	var/successSpawn = 0        //So we don't make a command report if nothing gets spawned.

/datum/event/borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 3)

/datum/event/borer_infestation/announce()
	if(successSpawn)
		command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", "lfesigns")

/datum/event/borer_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in machines)
		if(QDELETED(temp_vent))
			continue
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.PARENT1
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmosmch.len > 50)
				vents += temp_vent

	if(!vents.len)
		message_admins("An event attempted to spawn an borer but no suitable vents were found. Shutting down.")
		return

	var/list/candidates = get_alien_candidates()
	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/simple_animal/borer/new_borer = new(vent.loc)
		new_borer.key = C.key

		spawncount--
		successSpawn = 1
