/atom/movable/screen/alert/status_effect/swarm_gift
	name = "Swarm's Gift"
	desc = "The Swarm gifts you with increased efficency, as well as muffled disintegration noises. Prosper and multiply!"
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
	return isreplicator(owner)
