/*
 * Religion rite
 * Is a ritual performed by Chaplain at an altar.
 */
/datum/religion_rites
	/// Name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// Rite of this religion
	var/datum/religion/religion
	/// Just unique tip when examine altar
	var/list/tips = list()
	/// Length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// Strings that are by default said evenly throughout the rite
	var/list/ritual_invocations
	/// Message when you invoke
	var/invoke_msg
	/// Cost of rite in favor
	var/favor_cost = 0
	/// Needed aspects to get the rite.
	var/list/needed_aspects

/datum/religion_rites/proc/update_tip()
	if(religion)
		religion.update_rites()

/datum/religion_rites/proc/add_tips(tip)
	tips |= tip
	update_tip()

/datum/religion_rites/proc/remove_tip(tip)
	tips -= tip
	update_tip()

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
		on_invocation(user, AOG, stage)

	// Because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
	if(!can_invocate(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE

/datum/religion_rites/proc/on_chosen(mob/living/user, obj/structure/altar_of_gods/AOG)
	to_chat(user, "<span class='notice'>You begin preparations for the ritual...</span>")
	SEND_SIGNAL(src, COMSIG_RITE_ON_CHOSEN, user, AOG)
	return !user.is_busy(AOG) && do_after(user, target = AOG, delay = 10 SECONDS)

// Does something before the ritual and after checking the favor_cost of a ritual.
/datum/religion_rites/proc/before_perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	return !(SEND_SIGNAL(src, COMSIG_RITE_BEFORE_PERFORM, user, AOG) & COMPONENT_CHECK_FAILED)

// Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	SEND_SIGNAL(src, COMSIG_RITE_INVOKE_EFFECT, user, AOG)
	return TRUE

// Will not work if ritual_invocations is null.
/datum/religion_rites/proc/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	SEND_SIGNAL(src, COMSIG_RITE_ON_INVOCATION, user, AOG, stage)

/datum/religion_rites/proc/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	return !user.is_busy(AOG) && do_after(user, target = user, delay = ritual_length/ritual_invocations.len)

// Additional checks in performing rite
/datum/religion_rites/proc/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	return !(SEND_SIGNAL(src, COMSIG_RITE_REQUIRED_CHECK, user, AOG) & COMPONENT_CHECK_FAILED)
