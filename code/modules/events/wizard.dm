/datum/event/wizard
	announceWhen	= 12
	endWhen			= 120

/datum/event/wizard/start()
	if(!length(landmarks_list["Wizard"]))
		kill()
		return

	create_spawner(/datum/spawner/wizard_event)
