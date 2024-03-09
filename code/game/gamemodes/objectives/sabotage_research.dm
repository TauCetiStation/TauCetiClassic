/datum/objective/research_sabotage
	explanation_text = "Саботируйте сервера Отдела Исследований. Для этого вам выдана специальная дискета, вставьте её в консоль управления серверной ОИ для выполнения задания."
	required_equipment = /obj/item/weapon/disk/data/syndi
	global_objective = TRUE
	var/already_completed = FALSE

/datum/objective/research_sabotage/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/obj/item/weapon/disk/data/syndi
