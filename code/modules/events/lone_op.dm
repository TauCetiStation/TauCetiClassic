/datum/event/lone_op
	announceWhen	= 12
	endWhen			= 120

/datum/event/lone_op/start()
	if(!length(landmarks_list["Solo operative"]))
		kill()
		return

	create_spawner(/datum/spawner/lone_op_event)
