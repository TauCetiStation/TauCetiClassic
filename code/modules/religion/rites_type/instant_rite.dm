/*
 * Rites without standing for long time
 * Almost instant, depends on ritual_length
 */
/datum/religion_rites/instant

/datum/religion_rites/instant/get_count_steps()
	return 1 // Dont forget about invoke_msg

/datum/religion_rites/instant/can_start(mob/user, obj/AOG)
	if(user.is_busy(AOG))
		return FALSE

	return TRUE

/datum/religion_rites/instant/can_invocate(mob/user, obj/AOG)
	if(!do_after(user, target = AOG, delay = ritual_length, can_move = TRUE, extra_checks = CALLBACK(src, PROC_REF(be_nearby))))
		return FALSE

	return TRUE

/datum/religion_rites/instant/end(mob/user, obj/AOG)
	if(invoke_msg)
		user.say(invoke_msg)

/datum/religion_rites/instant/proc/be_nearby(mob/user, atom/target)
	if(get_dist(user, target) > 1)
		return FALSE
	return TRUE
