/datum/objective/research_sabotage
	explanation_text = "Sabotage the R&D servers and systems. Insert the diskette you were given into the R&D Server Controller to complete the objective."
	required_equipment = /obj/item/weapon/disk/data/syndi
	var/already_completed = FALSE

/datum/objective/research_sabotage/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/obj/item/weapon/disk/data/syndi

/obj/item/weapon/disk/data/syndi/examine(mob/user)
	. = ..()
	if(user.mind.special_role)
		to_chat(user, "<span class='warning'>This disk contains a computer virus to sabotage the station's systems!</span>")
