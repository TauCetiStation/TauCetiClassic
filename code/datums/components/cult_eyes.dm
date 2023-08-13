/**
 * # Cult eyes element
 *
 * Applies and removes the glowing cult eyes
 */
/datum/element/cult_eyes
	element_flags = ELEMENT_DETACH

/datum/element/cult_eyes/Attach(datum/target)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Register signals for mob transformation to prevent premature halo removal
	RegisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_MONKEY_HUMANIZE, COMSIG_HUMAN_MONKEYIZE), PROC_REF(set_eyes))
	set_eyes(target)

/**
 * Cult eye setter proc
 *
 * Changes the eye color, and adds the glowing eye trait to the mob.
 */
/datum/element/cult_eyes/proc/set_eyes(mob/living/target)
	SIGNAL_HANDLER
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.r_eyes = 255
		H.g_eyes = 0
		H.b_eyes = 0
		H.update_body()
		ADD_TRAIT(target, TRAIT_CULT_EYES, RELIGION_TRAIT)

/**
 * Detach proc
 *
 * Removes the eye color, and trait from the mob
 */
/datum/element/cult_eyes/Detach(mob/living/target, ...)
	REMOVE_TRAIT(target, TRAIT_CULT_EYES, RELIGION_TRAIT)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		H.r_eyes = rand(0,125)
		H.g_eyes = rand(0,255)
		H.b_eyes = rand(0,255)
		H.update_body()
	UnregisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE))
	return ..()
