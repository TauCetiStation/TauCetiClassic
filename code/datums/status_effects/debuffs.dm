//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS

/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_canmove()
			if(needs_update_stat || issilicon(owner))
				owner.update_stat()

/datum/status_effect/incapacitating/on_remove()
	owner.update_canmove()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /obj/screen/alert/status_effect/asleep
	needs_update_stat = TRUE
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	. = ..()
	if(.)
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(human_owner && !human_owner.client)
		duration = max(duration, world.time + 1 SECOND)

	owner.adjustHalLoss(-0.5) //reduce stamina loss by 0.5 per tick, 10 per 2 seconds

	if(human_owner)
		human_owner.drowsyness = max(0, human_owner.drowsyness * 0.997)
		human_owner.slurring = max(0, human_owner.slurring * 0.997)
		human_owner.confused = max(0, human_owner.confused * 0.997)

	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health)
			if(!carbon_owner || !carbon_owner.hal_crit)
				owner.emote("snore")

/obj/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

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
