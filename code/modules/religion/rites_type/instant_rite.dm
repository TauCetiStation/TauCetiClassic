/*
 * Rites without standing for long time
 * Almost instant, depends on ritual_length
 */
/datum/religion_rites/instant

/datum/religion_rites/instant/get_count_steps()
	return 1 // Dont forget about invoke_msg

/datum/religion_rites/instant/can_start(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(user.is_busy(AOG))
		return FALSE

	return TRUE

/datum/religion_rites/instant/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!do_after(user, target = user, delay = ritual_length))
		return FALSE

	return TRUE

/datum/religion_rites/instant/end(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(invoke_msg)
		user.say(invoke_msg)
