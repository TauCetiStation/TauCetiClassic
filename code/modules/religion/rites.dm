/*
 * Religion rite
 * Is a ritual performed by Chaplain at an altar.
 */
/datum/religion_rites
	/// name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// Just tip when examine altar
	var/tip_text
	/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// Strings that are by default said evenly throughout the rite
	var/list/ritual_invocations
	/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0

	var/list/needed_aspects

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!required_checks(user, AOG))
		return FALSE
	if(user.is_busy(AOG))
		return FALSE

	if(global.chaplain_religion && global.chaplain_religion.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE

	to_chat(user, "<span class='notice'>You begin performing the rite of [name]...</span>")

	if(!ritual_invocations)
		if(!user.is_busy(AOG) && do_after(user, target = AOG, delay = ritual_length))
			return TRUE
		return FALSE

	if(!before_perform_rite(user, AOG))
		return FALSE

	var/first_invoke = TRUE
	var/stage = 0
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(!can_invocate(user, AOG))
			SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
			return FALSE
		user.say(i)
		stage += 1
		if(!on_invocation(user, AOG, stage))
			SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
			return FALSE

	// Because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
	if(!can_invocate(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE

/datum/religion_rites/proc/on_chosen(mob/living/user, obj/structure/altar_of_gods/AOG)
	to_chat(user, "<span class='notice'>You begin preparations for the ritual...</span>")
	if(!do_after(user, target = AOG, delay = 10 SECONDS))
		return FALSE
	return TRUE

// Does something before the ritual and after checking the favor_cost of a ritual.
/datum/religion_rites/proc/before_perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(SEND_SIGNAL(src, COMSIG_RITE_BEFORE_PERFORM, user, AOG) & COMPONENT_CHECK_FAILED)
		return FALSE
	return TRUE

// Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!required_checks(user, AOG))
		return FALSE
	return TRUE

// Does a thing on each invocation, return FALSE to cancel ritual performance.
// Will not work if ritual_invocations is null.
/datum/religion_rites/proc/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	SEND_SIGNAL(src, COMSIG_RITE_ON_INVOCATION, user, AOG, stage)
	return TRUE

/datum/religion_rites/proc/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	return !user.is_busy(AOG) && do_after(user, target = user, delay = ritual_length/ritual_invocations.len)

// Additional checks in performing rite
/datum/religion_rites/proc/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(SEND_SIGNAL(src, COMSIG_RITE_REQUIRED_CHECK, user, AOG) & COMPONENT_CHECK_FAILED)
		return FALSE
	return TRUE
