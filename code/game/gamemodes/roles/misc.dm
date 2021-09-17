/datum/role/protector
	name = PROTECTOR
	id = PROTECTOR

	logo_state = "protector-logo"

/datum/role/protector/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "Тебе хочется защитить кого-то на станции!")
	to_chat(antag.current, "Однако, тебя всё ещё связывают правила сервера, и применять летальную силу по отношению к обидчику цели следует лишь в крайнем случае.")
	to_chat(antag.current, "Нет, арестовывающие офицеры угрозы не предтставляют.")

/datum/role/protector/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/escape)
	return TRUE
