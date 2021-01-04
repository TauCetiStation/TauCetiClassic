/*
 * Religion rite
 * Is a ritual performed by Chaplain at an altar.
 * A very good example of creating a ritual in code\modules\religion\rites_type\standing_rite.dm
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
	/// Cost of rite in piety
	var/piety_cost = 0
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

// How many steps there should be
/datum/religion_rites/proc/get_count_steps()
	return

// Called after on_chosen and checks on cost
/datum/religion_rites/proc/can_start(mob/living/user, obj/structure/altar_of_gods/AOG)
	return TRUE

// The main proc. It allows you to move from one step to the next
/datum/religion_rites/proc/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	return TRUE

// Event after can_invocate execution
/datum/religion_rites/proc/rite_step(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	return

// Event after the end of the ritual, but before removing favor and invoke_effect
/datum/religion_rites/proc/end(mob/living/user, obj/structure/altar_of_gods/AOG)
	return

// Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_RITE_INVOKE_EFFECT, user, AOG)
	return TRUE

// Return the ritual variables to their original state or change them in some way
/datum/religion_rites/proc/reset_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	return



/datum/religion_rites/proc/can_start_wrapper(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(SEND_SIGNAL(src, COMSIG_RITE_CAN_START, user, AOG) & COMPONENT_CHECK_FAILED)
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE

	if(!religion.check_costs(favor_cost, user = user))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE

	if(!can_start(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE

	to_chat(user, "<span class='notice'>You begin performing the rite of [name]...</span>")

	return TRUE

/datum/religion_rites/proc/start(mob/living/user, obj/structure/altar_of_gods/AOG)
	SEND_SIGNAL(src, list(COMSIG_RITE_STARTED), user, AOG)
	RegisterSignal(src, list(COMSIG_RITE_STEP_ENDED), .proc/try_next_step)
	try_next_step(src, user, AOG, 1)

/datum/religion_rites/proc/try_next_step(datum/source, mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	if(!can_step(user, AOG, current_stage))
		return FALSE
	rite_step_wrapper(user, AOG, current_stage)

/datum/religion_rites/proc/can_step(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	if(current_stage > get_count_steps())
		end_wrapper(user, AOG)
		return FALSE
	if(!can_invocate(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE
	return TRUE

/datum/religion_rites/proc/rite_step_wrapper(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	SEND_SIGNAL(src, COMSIG_RITE_IN_STEP, user, AOG, current_stage)

	rite_step(user, AOG, current_stage)

	step_end(user, AOG, current_stage)

/datum/religion_rites/proc/step_end(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	SEND_SIGNAL(src, COMSIG_RITE_STEP_ENDED, user, AOG, current_stage + 1)

/datum/religion_rites/proc/end_wrapper(mob/living/user, obj/structure/altar_of_gods/AOG)
	end(user, AOG)
	religion.adjust_favor(-favor_cost)
	invoke_effect(user, AOG)
	reset_rite_wrapper(src, user, AOG)

/datum/religion_rites/proc/reset_rite_wrapper(datum/source, mob/living/user, obj/structure/altar_of_gods/AOG)
	UnregisterSignal(src, list(COMSIG_RITE_STEP_ENDED, COMSIG_RITE_FAILED_CHECK))
	AOG.reset_rite() // Very bad.
	reset_rite()

/datum/religion_rites/proc/on_chosen(mob/living/user, obj/structure/altar_of_gods/AOG)
	to_chat(user, "<span class='notice'>You begin preparations for the ritual...</span>")
	SEND_SIGNAL(src, COMSIG_RITE_ON_CHOSEN, user, AOG)
	return TRUE

/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	RegisterSignal(src, list(COMSIG_RITE_FAILED_CHECK), .proc/reset_rite_wrapper)
	if(!on_chosen(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE

	if(!can_start_wrapper(user, AOG))
		return FALSE

	start(user, AOG)
	return TRUE
