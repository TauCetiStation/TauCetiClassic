//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

/datum/event/borer_infestation
	announceWhen = 400
	announcement = new /datum/announcement/centcomm/aliens

	var/spawncount = 1
	var/successSpawn = FALSE //So we don't make a command report if nothing gets spawned.

/datum/event/borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 3)

/datum/event/borer_infestation/announce()
	if(successSpawn)
		announcement.play()

/datum/event/borer_infestation/start()
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn a borers, but no suitable vents were found. Shutting down.")
		kill()
		return

	create_uniq_faction(/datum/faction/borers)

	create_spawners(/datum/spawner/borer_event, spawncount)
