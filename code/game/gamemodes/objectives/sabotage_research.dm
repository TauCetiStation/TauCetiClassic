/datum/objective/research_sabotage
	explanation_text = "Саботируйте сервера Отдела Исследований. Для этого вам выдана специальная дискетта, вставьте её в консоль управления серверной."
	required_equipment = /obj/item/weapon/disk/data/syndi
	var/already_completed = FALSE

/datum/objective/research_sabotage/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/obj/item/weapon/disk/data/syndi
