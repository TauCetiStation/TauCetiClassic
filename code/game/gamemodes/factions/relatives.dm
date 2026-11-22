var/global/relatives_id_number = 1

/datum/faction/relatives
	name = "Семья"
	ID = F_RELATIVES

	initroletype = /datum/role/relative
	roletype = /datum/role/relative

	min_roles = 1
	max_roles = 2

	rounstart_populate = FALSE

	hide_from_memories = TRUE

	var/relatives_id

/datum/faction/relatives/New()
	relatives_id = global.relatives_id_number
	relatives_id_number++
	if(relatives_id_number > 3)
		relatives_id_number = 1
	logo_state = "family_[relatives_id]"
	..()

/datum/faction/relatives/custom_result()
	for(var/datum/role/relative/R in members)
		if(!ishuman(R.antag.current))
			continue
		var/mob/living/carbon/human/H = R.antag.current
		if(H.stat != CONSCIOUS)
			return "<span class='red'>Родственник не выжил</span>"

	return "<span class='green'>Родственники живы</span>"

/datum/faction/relatives/GetScoreboard()
	var/score_results = custom_result()
	score_results += "<br>"

	return score_results
