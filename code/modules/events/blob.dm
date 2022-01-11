/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return

	create_spawner(/datum/spawner/blob_event, "blob_event")
