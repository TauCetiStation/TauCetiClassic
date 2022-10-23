/datum/objective/gang/steal_gold
	explanation_text = "Слушайте сюда, ребята. У меня есть план. Еще один балл в нашу копилку в этом дерьмовом маленьком гетто. Золотые слитки, друзья. Достаньте как можно больше золота! Распределите его между собой ради побега. Убедитесь, что у каждого есть хотя бы 1 слиток. После этого будет космическое манго на Таити. Просто немного поверь в себя."

/datum/objective/gang/steal_gold/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue // dead people cant really do the objective lol
		var/list/items_to_check = M.GetAllContents()
		var/gold_finded = locate(/obj/item/stack/sheet/mineral/gold) in items_to_check
		if(gold_finded)
			continue
		return OBJECTIVE_LOSS // didnt pass the bar check, no point in continuing to loop
	return OBJECTIVE_WIN
