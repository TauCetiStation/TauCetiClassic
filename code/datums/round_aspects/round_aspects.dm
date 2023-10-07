/datum/round_aspect
	var/name = ROUND_ASPECT_NAME
	// Game announcement after initialization of the subsystem and selection of aspect. Leave blank if you don't want anything.
	var/game_announcement
	// Minimum number of players to select an aspect.
	var/min_players

/datum/round_aspect/proc/on_start()
	return

/datum/round_aspect/agent_of_high_affairs
	name = ROUND_ASPECT_HF_AGENT
	min_players = 0

/datum/round_aspect/rearm_energy
	name = ROUND_ASPECT_REARM_ENERGY
	game_announcement = "<span class='warning'>Руководство Нанотрасен решило, что баллистическое оружие является слишком негуманным. Поэтому всё баллистическое оружие на всех станциях заменили на энергетическое.</span>"
	min_players = 0

/datum/round_aspect/rearm_laser/on_start()
	new /datum/event/feature/area/replace/station_rearmament_energy

/datum/round_aspect/rearm_ballistic
	name = ROUND_ASPECT_REARM_BULLETS
	game_announcement = "<span class='warning'>Руководство Нанотрасен решило, что энергетическое оружие является слишком дорогим и неэффективным. Поэтому всё энергооружие на всех станциях заменили на баллистическое.</span>"
	min_players = 0

/datum/round_aspect/rearm_ballistic/on_start()
	new /datum/event/feature/area/replace/station_rearmament_bullets
