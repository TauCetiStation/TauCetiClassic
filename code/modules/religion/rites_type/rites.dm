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

/datum/religion_rites/proc/get_count_steps()
	return ritual_invocations.len

/datum/religion_rites/proc/can_start(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!required_checks(user, AOG))
		return FALSE

	if(!religion.check_costs(favor_cost, user = user))
		return FALSE

	to_chat(user, "<span class='notice'>You begin performing the rite of [name]...</span>")

	if(!before_perform_rite(user, AOG))
		to_chat(world, "if(!before_perform_rite(user, AOG))")
		return FALSE

	return TRUE

/datum/religion_rites/proc/start(mob/living/user, obj/structure/altar_of_gods/AOG)
	RegisterSignal(src, list(COMSIG_RITE_STEP_ENDED), .proc/try_next_step)
	try_next_step(src, user, AOG, 1)

/datum/religion_rites/proc/try_next_step(datum/source, mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	if(!can_step(user, AOG, current_stage))
		to_chat(world, "if(!can_step())")
		return FALSE
	rite_step_wrapper(user, AOG, current_stage)

/datum/religion_rites/proc/can_step(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	if(current_stage > get_count_steps())
		end_wrapper(user, AOG)
		to_chat(world, "if(current_stage > get_count_steps())")
		return FALSE
	if(!can_invocate(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		to_chat(world, "!can_invocate(user, AOG)")
		return FALSE
	return TRUE

/datum/religion_rites/proc/rite_step_wrapper(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	SEND_SIGNAL(src, COMSIG_RITE_IN_STEP, user, AOG, current_stage)
	to_chat(world, "step started")
	on_invocation(user, AOG, current_stage)

	rite_step(user, AOG, current_stage)

	step_end(user, AOG, current_stage)

/datum/religion_rites/proc/rite_step(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	return

/datum/religion_rites/proc/step_end(mob/living/user, obj/structure/altar_of_gods/AOG, current_stage)
	SEND_SIGNAL(src, COMSIG_RITE_STEP_ENDED, user, AOG, current_stage + 1)
	to_chat(world, "step ended")

/datum/religion_rites/proc/end_wrapper(mob/living/user, obj/structure/altar_of_gods/AOG)
	UnregisterSignal(src, list(COMSIG_RITE_STEP_ENDED))
	end(user, AOG)
	religion.adjust_favor(-favor_cost)
	invoke_effect(user, AOG)

/datum/religion_rites/proc/end(mob/living/user, obj/structure/altar_of_gods/AOG)
	return

/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!on_chosen(user, AOG))
		return FALSE

	if(!can_start(user, AOG))
		return FALSE

	start(user, AOG)
	return TRUE

/datum/religion_rites/proc/on_chosen(mob/living/user, obj/structure/altar_of_gods/AOG)
	to_chat(user, "<span class='notice'>You begin preparations for the ritual...</span>")
	SEND_SIGNAL(src, COMSIG_RITE_ON_CHOSEN, user, AOG)
	return TRUE

// Does something before the ritual and after checking the favor_cost of a ritual.
/datum/religion_rites/proc/before_perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	return !(SEND_SIGNAL(src, COMSIG_RITE_BEFORE_PERFORM, user, AOG) & COMPONENT_CHECK_FAILED)

// Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_RITE_INVOKE_EFFECT, user, AOG)
	return TRUE

// Will not work if ritual_invocations is null.
/datum/religion_rites/proc/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_RITE_ON_INVOCATION, user, AOG, stage)

/datum/religion_rites/proc/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	return TRUE

// Additional checks in performing rite
/datum/religion_rites/proc/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	SHOULD_CALL_PARENT(TRUE)
	return !(SEND_SIGNAL(src, COMSIG_RITE_REQUIRED_CHECK, user, AOG) & COMPONENT_CHECK_FAILED)
