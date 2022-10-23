/datum/objective/gang/capture_station
	explanation_text = "В последнее время было потеряли слишком много територий. Мы должны вернуть это дерьмо обратно. Убедитесь, что как минимум 45 комнат будут помечено нашей бандой."

/datum/objective/gang/capture_station/check_completion()
	if(!istype(faction, /datum/faction/gang))
		return OBJECTIVE_LOSS
	var/datum/faction/gang/G = faction
	var/tag_amount = 0
	for(var/T in G.gang_tags)
		var/obj/effect/decal/cleanable/crayon/gang/tag = T
		if(tag.my_gang.gang_id == G.gang_id)
			tag_amount++
	if(tag_amount >= 45)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
