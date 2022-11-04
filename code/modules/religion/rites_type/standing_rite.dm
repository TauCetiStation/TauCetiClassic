/*
 * Standing or AFK
 * The person just has to stand and say the words
 */
/datum/religion_rites/standing

/datum/religion_rites/standing/get_count_steps()
	if(ritual_invocations)
		return ritual_invocations.len + 1 // Dont forget about invoke_msg
	return 1

/datum/religion_rites/standing/on_chosen(mob/user, obj/AOG)
	if(!..())
		return FALSE
	return !user.is_busy(AOG) && do_after(user, target = AOG, delay = 10 SECONDS)

/datum/religion_rites/standing/can_start(mob/user, obj/AOG)
	if(user.is_busy(AOG))
		return FALSE

	return TRUE

/datum/religion_rites/standing/can_invocate(mob/user, obj/AOG)
	if(user.is_busy(AOG))
		return FALSE

	var/length = ritual_invocations ? ritual_invocations.len : 1
	if(!do_after(user, target = user, delay = ritual_length/length))
		return FALSE

	return TRUE

/datum/religion_rites/standing/rite_step(mob/user, obj/AOG, current_stage)
	if(ritual_invocations && current_stage < get_count_steps())
		user.say(ritual_invocations[current_stage])

/datum/religion_rites/standing/end(mob/user, obj/AOG)
	if(invoke_msg)
		user.say(invoke_msg)
