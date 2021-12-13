/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return

	create_spawners(/datum/spawner/blob_event, 1, 3 MINUTES)
