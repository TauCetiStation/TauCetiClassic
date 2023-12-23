/datum/event/wizard
	announceWhen	= 12
	endWhen			= 120

/datum/event/wizard/start()
	if(!length(wizardstart))
		kill()
		return

	create_spawner(/datum/spawner/wizard_event)
