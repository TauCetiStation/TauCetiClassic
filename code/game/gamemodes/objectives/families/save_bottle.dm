/datum/objective/gang/save_bottle
	explanation_text = "У нас начинает заканчиваться водка на базе. Братан, убедись, что у каждого нашего товарища будет емкость с этой божьей росой."

/datum/objective/gang/save_bottle/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue // dead people cant really do the objective lol
		var/list/items_to_check = M.GetAllContents()
		var/vodka_finded = FALSE
		for(var/obj/item/weapon/reagent_containers/RC in items_to_check)
			if(!RC.reagents || !RC.reagents.reagent_list)
				continue
			if(locate(/datum/reagent/consumable/ethanol/vodka) in RC.reagents.reagent_list)
				vodka_finded = TRUE
				break
		if(!vodka_finded)
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
