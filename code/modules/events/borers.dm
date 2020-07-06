//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

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
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		kill()
		return

	while(spawncount >= 1 && vents.len)
		var/obj/vent = pick_n_take(vents)
		new /mob/living/simple_animal/borer(vent.loc)
		successSpawn = TRUE
		spawncount--
