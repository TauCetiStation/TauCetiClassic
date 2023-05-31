/datum/event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = FALSE  //So we don't make a command report if nothing gets spawned.

	announcement = new /datum/announcement/centcomm/aliens


/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(3, 4)

/datum/event/alien_infestation/announce()
	if(successSpawn)
		announcement.play()

/datum/event/alien_infestation/start()
	if(!aliens_allowed)
		message_admins("An event attempted to spawn an alien but aliens are locked down. Shutting down.")
		kill()
		return
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return

	create_spawners(/datum/spawner/alien_event, spawncount)
