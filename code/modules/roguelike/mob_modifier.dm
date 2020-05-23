var/global/list/incompatible_mob_modifiers = list(
	list(/datum/component/mob_modifier/healthy, /datum/component/mob_modifier/frail),
)

/*
 * Mob modifier datum.
 * Is used to make some mobs more or less unique.
 */
/datum/component/mob_modifier
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// The name of this modifier.
	var/modifier_name
	/// The strength of this modifier's effect.
	var/strength = 1
	/// The maximum strength value allowed by this modifier in generation.
	var/max_strength = 3

	/// How much "rarity points" does this modifier cost? Negative costs used for negative effects.
	var/rarity_cost = 1

	/// /datum/name_modifier to be applied to mob.
	var/name_modifier_type

	/// Whether the component was succesfully applied.
	var/applied = FALSE

/datum/component/mob_modifier/Initialize(strength)
	if(!istype(parent, /mob/living/simple_animal/hostile))
		return COMPONENT_INCOMPATIBLE

	src.strength = strength

	if(apply())
		applied = TRUE
	else
		return COMPONENT_NOT_ATTACHED

/datum/component/mob_modifier/InheritComponent(datum/component/mob_modifier/MM, i_am_original, strength)
	update(src.strength + strength)

/datum/component/mob_modifier/Destroy()
	if(applied)
		revert()
	return ..()

/// Is called when our strength level is changed.
/datum/component/mob_modifier/proc/update(new_strength)
	revert()
	strength = new_strength
	apply()

// How is mob's info modified by this modifier. Return TRUE if succesfully applied.
/datum/component/mob_modifier/proc/apply()
	if(name_modifier_type)
		SEND_SIGNAL(parent, COMSIG_NAME_MOD_ADD, name_modifier_type, strength)
	return TRUE

// How to revert mob's everything after removing this modifier. Return TRUE if succesfully reverted.
/datum/component/mob_modifier/proc/revert()
	if(name_modifier_type)
		SEND_SIGNAL(parent, COMSIG_NAME_MOD_REMOVE, name_modifier_type, strength)
	return TRUE
