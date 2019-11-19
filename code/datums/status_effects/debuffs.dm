//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_canmove()

/datum/status_effect/incapacitating/on_remove()
	owner.update_canmove()

//STASIS
/datum/status_effect/incapacitating/stasis_bag // don't mistake with TG's stasis.
	id = "stasis_bag"
	duration = -1
	tick_interval = 10
	alert_type = /obj/screen/alert/status_effect/stasis_bag
	var/last_dead_time

/datum/status_effect/incapacitating/stasis_bag/proc/update_time_of_death()
	if(last_dead_time)
		var/delta = world.time - last_dead_time
		var/new_timeofdeath = owner.timeofdeath + delta
		owner.timeofdeath = new_timeofdeath
		owner.tod = worldtime2text()
		last_dead_time = null
	if(owner.stat == DEAD)
		last_dead_time = world.time

/datum/status_effect/incapacitating/stasis_bag/proc/handle_stasis_bag()
	// First off, there's no oxygen supply, so the mob will slowly take brain damage
	owner.adjustBrainLoss(0.1)

	// Next, the method to induce stasis has some adverse side-effects, manifesting
	// as cloneloss
	owner.adjustCloneLoss(0.1)

/datum/status_effect/incapacitating/stasis_bag/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	. = ..()
	update_time_of_death()

/datum/status_effect/incapacitating/stasis_bag/tick()
	update_time_of_death()
	handle_stasis_bag()

/datum/status_effect/incapacitating/stasis_bag/on_remove()
	update_time_of_death()
	return ..()

/datum/status_effect/incapacitating/stasis_bag/be_replaced()
	update_time_of_death()
	return ..()

/obj/screen/alert/status_effect/stasis_bag
	name = "Stasis Bag"
	desc = "Your biological functions have halted. You could live forever this way, but it's pretty boring."
	icon_state = "stasis"
