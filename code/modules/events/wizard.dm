/datum/event/wizard
	announceWhen	= 12
	endWhen			= 120

/datum/event/wizard/start()
	if(!length(wizardstart))
		kill()
		to_chat(world, "AVADA CEDAVRA")
		return

	create_spawner(/datum/spawner/wizard_event)
