/datum/faction/zombie
	name = F_ZOMBIES
	ID = F_ZOMBIES

	initroletype = /datum/role/zombie

	logo_state = "zombie-logo"

	COOLDOWN_DECLARE(last_check)

/datum/faction/zombie/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/turn_into_zombie)

/datum/faction/zombie/check_win()
	if(COOLDOWN_FINISHED(src, last_check))
		return FALSE
	COOLDOWN_START(src, last_check, 1 MINUTE)
	if(round(length(members) / check_crew()) >= 0.8)
		if(SSshuttle.location || SSshuttle.direction) //If traveling or docked somewhere other than idle at command, don't call.
			return FALSE
		SSshuttle.incall(0.5)
		SSshuttle.announce_emer_called.message = "Карантин прорван, дальнейшая локализация угрозы не представляется возможной. Выжившему персоналу предписано прибыть на эвакуацию и удерживать оборону. Эвакуационный шаттл прибудет через несколько минут."
		SSshuttle.announce_emer_called.play()

