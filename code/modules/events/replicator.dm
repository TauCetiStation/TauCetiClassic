/datum/event/replicator
	announceWhen	= 12
	endWhen			= 120

/datum/event/replicator/start()
	if(!length(landmarks_list["replicator"]))
		kill()
		return

	create_spawner(/datum/spawner/replicator_event)
