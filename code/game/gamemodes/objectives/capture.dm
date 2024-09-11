/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/holding/A = locate()
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(M.stat==DEAD)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
		captured_amount+=0.1
	for(var/mob/living/carbon/xenomorph/larva/M in A)//Larva are important for research.
		if(M.stat==DEAD)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/xenomorph/humanoid/M in A)//Aliens are worth twice as much as humans.
		if(isxenoqueen(M))//Queens are worth three times as much as humans.
			if(M.stat==DEAD)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat==DEAD)
			captured_amount+=1
			continue
		captured_amount+=2
	if(captured_amount<target_amount)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
