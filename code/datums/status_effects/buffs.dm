/atom/movable/screen/alert/status_effect/swarm_gift
	name = "Swarm's Gift"
	desc = "The Swarm gifts you with increased efficency. Prosper and multiply!"
	icon_state = "swarm_gift"

/datum/status_effect/swarm_gift
	id = "swarm_gift"
	alert_type = /atom/movable/screen/alert/status_effect/swarm_gift

/datum/status_effect/swarm_gift/on_creation(mob/living/new_owner, duration)
	. = ..()
	if(!.)
		return
	src.duration = world.time + duration

/datum/status_effect/swarm_gift/on_apply()
	if(!istype(owner, /mob/living/simple_animal/replicator))
		return FALSE

	var/mob/living/simple_animal/replicator/R = owner

	R.efficency *= 2.0

	return TRUE

/datum/status_effect/swarm_gift/on_remove()
	var/mob/living/simple_animal/replicator/R = owner
	R.efficency *= 0.5
