/datum/round_aspect
	var/name
	// Game announcement after initialization of the subsystem and selection of aspect. Leave blank if you don't want anything.
	var/game_announcement

/datum/round_aspect/proc/on_start()
	return

/datum/round_aspect/agent_of_high_affairs
	name = ROUND_ASPECT_HF_AGENT

/datum/round_aspect/rearm_energy
	name = ROUND_ASPECT_REARM_ENERGY
	game_announcement = "<span class='warning'>Руководство НаноТрейзен решило, что баллистическое оружие является слишком негуманным. Поэтому всё баллистическое оружие на всех станциях заменили на энергетическое.</span>"

/datum/round_aspect/rearm_energy/on_start()
	new /datum/event/feature/area/replace/station_rearmament_energy

/datum/round_aspect/rearm_ballistic
	name = ROUND_ASPECT_REARM_BULLETS
	game_announcement = "<span class='warning'>Руководство НаноТрейзен решило, что энергетическое оружие является слишком дорогим и неэффективным. Поэтому всё энергооружие на всех станциях заменили на баллистическое.</span>"

/datum/round_aspect/rearm_ballistic/on_start()
	new /datum/event/feature/area/replace/station_rearmament_bullets
