/datum/role/nanotrasen_agent
	name = NANOTRASEN_AGENT
	id = NANOTRASEN_AGENT

	logo_state = "nano-logo"

/datum/role/nanotrasen_agent/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<span class = 'info'><B>Вы - <font color='blue'>Тайный агент Нанотрейзен</font>!</B></span>")
	to_chat(antag.current, "Совсем недавно отдел контрразведки Нанотрейзен обнаружил, что весь командный состав [station_name_ru()] оказался предателями, работающими на Синдикат.")
	to_chat(antag.current, "<B>Вы должны уничтожить глав, при этом сохраняя секретность.</B></span>")

/datum/role/nanotrasen_agent/forgeObjectives()
	if(!..())
		return FALSE
	var/list/heads = get_living_heads()

	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/assassinate/A = AppendObjective(/datum/objective/target/assassinate, TRUE)
	return TRUE
