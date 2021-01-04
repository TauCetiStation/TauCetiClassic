/*
 * Standing or AFK
 * The person just has to stand and say the words
 */
/datum/religion_rites/standing

/datum/religion_rites/standing/get_count_steps()
	return ritual_invocations.len + 1 // Dont forget about invoke_msg

/datum/religion_rites/standing/on_chosen(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE
	return !user.is_busy(AOG) && do_after(user, target = AOG, delay = 10 SECONDS)

/datum/religion_rites/standing/can_start(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(user.is_busy(AOG))
		return FALSE

	if(!ritual_invocations)
		return FALSE

	return TRUE

/datum/religion_rites/standing/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(user.is_busy(AOG))
		return FALSE

	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
		return FALSE

	return TRUE

/datum/religion_rites/standing/rite_step(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	if(current_stage < get_count_steps())
		user.say(ritual_invocations[current_stage])

/datum/religion_rites/standing/end(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(invoke_msg)
		user.say(invoke_msg)
