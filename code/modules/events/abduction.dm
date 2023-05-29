/datum/event/abduction
	announceWhen = 12
	endWhen      = 120

/datum/event/abduction/start()
	create_spawner(/datum/spawner/abductor/scientist)
	create_spawner(/datum/spawner/abductor/scientist/second)
	create_spawner(/datum/spawner/abductor/scientist/third)
	create_spawner(/datum/spawner/abductor/scientist/fourth)
	create_spawner(/datum/spawner/abductor/agent)
	create_spawner(/datum/spawner/abductor/agent/second)
	create_spawner(/datum/spawner/abductor/agent/third)
	create_spawner(/datum/spawner/abductor/agent/fourth)
