/datum/event/cult
	announceWhen	= 12
	endWhen			= 120

/datum/event/cult/start()
	create_spawners(/datum/spawner/maelstrom, 4)
