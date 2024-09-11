/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/start()
	if(!length(landmarks_list["blobstart"])) // add return codes for create_spawner
		kill()
		return

	create_spawner(/datum/spawner/blob_event)
