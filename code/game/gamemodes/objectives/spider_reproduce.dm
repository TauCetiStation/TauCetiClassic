/datum/objective/spider_reproduce
	explanation_text = "Reproduce at least once."

/datum/objective/spider_reproduce/check_completion()
	if(owner && owner.current)
		var/mob/living/simple_animal/hostile/giant_spider/S = owner.current
		if(istype(S) && S.reproduced)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/spider_evolve
	explanation_text = "Evolve."

/datum/objective/spider_evolve/check_completion()
	if(owner && owner.current)
		if(is_type_in_list(owner.current, list(
				/mob/living/simple_animal/hostile/giant_spider/tarantula,
				/mob/living/simple_animal/hostile/giant_spider/viper,
				/mob/living/simple_animal/hostile/giant_spider/midwife)))
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
