/datum/objective/gang/save_bottle
	explanation_text = "У нас начинают заканчиваться припасы на базе. Братан, убедись, что у каждого нашего товарища будет бутылка какой-нибудь выбивки."

/datum/objective/gang/save_bottle/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue // dead people cant really do the objective lol
		var/list/items_to_check = M.GetAllContents()
		var/bottle_finded = locate(/obj/item/weapon/reagent_containers/food/drinks/bottle) in items_to_check
		if(bottle_finded)
			continue
		return OBJECTIVE_LOSS // didnt pass the bottle check, no point in continuing to loop
	return OBJECTIVE_WIN
