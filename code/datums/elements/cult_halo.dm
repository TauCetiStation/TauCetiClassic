/**
 * # Cult halo element
 *
 * Applies and removes the cult halo
 */
/datum/element/cult_halo
	element_flags = ELEMENT_DETACH

/datum/element/cult_halo/Attach(datum/target)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Register signals for mob transformation to prevent premature halo removal
	RegisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_MONKEY_HUMANIZE, COMSIG_HUMAN_MONKEYIZE), PROC_REF(set_halo))
	set_halo(target)

/**
 * Halo setter proc
 *
 * Adds the cult halo overlays, and adds the halo trait to the mob.
 */
/datum/element/cult_halo/proc/set_halo(mob/living/target)
	if(!HAS_TRAIT(target, TRAIT_CULT_HALO))
		ADD_TRAIT(target, TRAIT_CULT_HALO, RELIGION_TRAIT)
	var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', "halo[rand(1, 6)]", EXTERNAL_APPEARANCE)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		human_parent.overlays_standing[EXTERNAL_APPEARANCE] = new_halo_overlay
		human_parent.apply_standing_overlay(EXTERNAL_APPEARANCE)
	else
		target.add_overlay(new_halo_overlay)

/datum/element/cult_halo/proc/reset_halo(mob/living/target, mob/living/new_mob)
	SIGNAL_HANDLER
	set_halo(new_mob)

/**
 * Detach proc
 *
 * Removes the halo overlays, and trait from the mob
 */
/datum/element/cult_halo/Detach(mob/living/target, ...)
	REMOVE_TRAIT(target, TRAIT_CULT_HALO, RELIGION_TRAIT)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		human_parent.remove_standing_overlay(EXTERNAL_APPEARANCE)
		//human_parent.update_body() maybe it was meant for something, but unlike cult_eyes which changes eye color and so required to update_body, this one does nothing, but instead of deleting i'll leave it commented as it was ported from other codebase and maybe there it meant something
	else
		target.cut_overlay(EXTERNAL_APPEARANCE)
	UnregisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE))
	return ..()
