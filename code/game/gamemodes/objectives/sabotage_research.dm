/datum/objective/research_sabotage
	explanation_text = "Саботируйте сервера и системы ОИР. Вставьте полученную вами дискету в контроллер сервера ОИР, чтобы выполнить задание."
	required_equipment = /obj/item/weapon/disk/data/syndi
	global_objective = TRUE
	var/already_completed = FALSE

/datum/objective/research_sabotage/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
