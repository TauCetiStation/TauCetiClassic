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

	/// Whether removing this modifier should update all other modifiers.
	var/updates = FALSE
	/// Whether this modifier needs updates.
	var/need_updates = FALSE

/datum/component/mob_modifier/Initialize(strength)
	if(!istype(parent, /mob/living/simple_animal/hostile))
		return COMPONENT_INCOMPATIBLE

	src.strength = strength

	if(!apply())
		return COMPONENT_NOT_ATTACHED


	if(need_updates)
		RegisterSignal(parent, list(COMSIG_MOB_MOD_UPDATE), .proc/on_revert)

	applied = TRUE

/datum/component/mob_modifier/InheritComponent(datum/component/mob_modifier/MM, i_am_original, strength)
	update(src.strength + strength)

/datum/component/mob_modifier/Destroy()
	if(applied)
		revert()
	return ..()

/// Is called when our strength level is changed.
/datum/component/mob_modifier/proc/update(new_strength)
	revert(update = TRUE)
	strength = new_strength
	apply(update = TRUE)

/// How is mob's info modified by this modifier. Return TRUE if succesfully applied.
/// Update param is whether revert was called via update() method, so don't re-apply some one-time stuff, since it wasn't reverted.
/datum/component/mob_modifier/proc/apply(update = FALSE)
	if(name_modifier_type)
		SEND_SIGNAL(parent, COMSIG_NAME_MOD_ADD, name_modifier_type, strength)

	return TRUE

/// How to revert mob's everything after removing this modifier.
/// Due to the update logic, only should be called after all the previous revertions occur, at the end of override.
/// Update param is whether revert was called via update() method, so don't remove some one-time stuff only to re-create it.
/datum/component/mob_modifier/proc/revert(update = FALSE)
	if(name_modifier_type)
		SEND_SIGNAL(parent, COMSIG_NAME_MOD_REMOVE, name_modifier_type, strength)

	if(!update && updates)
		SEND_SIGNAL(parent, COMSIG_MOB_MOD_UPDATE, src)

/// How does this modifier react to revert of other modifier.
/datum/component/mob_modifier/proc/on_revert(datum/source, datum/component/mob_modifier/reverting)
	update(strength)
