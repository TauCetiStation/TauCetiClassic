/atom/movable/screen/alert/status_effect/array_turn_back
	name = "Turn Back"
	desc = "Affect the replicator you were controlling before this one."
	icon_state = "swarm_turn_back"

	var/mob/living/simple_animal/hostile/replicator/remembered

/atom/movable/screen/alert/status_effect/array_turn_back/Destroy()
	UnregisterSignal(remembered, list(COMSIG_MOB_DIED, COMSIG_LOGIN, COMSIG_PARENT_QDELETING))
	remembered = null
	return ..()

/atom/movable/screen/alert/status_effect/array_turn_back/Click()
	if(!mob_viewer)
		return
	if(mob_viewer.incapacitated())
		return
	if(!mob_viewer.mind)
		return
	if(!isreplicator(mob_viewer))
		return
	var/mob/living/simple_animal/hostile/replicator/R = mob_viewer
	var/mob/living/simple_animal/hostile/replicator/target = remembered
	R.remove_status_effect(STATUS_EFFECT_ARRAY_TURN_BACK)
	R.transfer_control(target, alert=TRUE)

/atom/movable/screen/alert/status_effect/array_turn_back/proc/remember(mob/living/simple_animal/hostile/replicator/R)
	remembered = R
	RegisterSignal(R, list(COMSIG_MOB_DIED, COMSIG_LOGIN, COMSIG_PARENT_QDELETING), PROC_REF(forget))

/atom/movable/screen/alert/status_effect/array_turn_back/proc/forget(datum/source)
	var/mob/living/simple_animal/hostile/replicator/R = mob_viewer
	R.remove_status_effect(STATUS_EFFECT_ARRAY_TURN_BACK)


/datum/status_effect/array_turn_back
	id = "array_transfer_back"
	alert_type = /atom/movable/screen/alert/status_effect/array_turn_back

/datum/status_effect/array_turn_back/on_creation(mob/living/new_owner, mob/living/simple_animal/hostile/replicator/R, duration)
	. = ..()
	if(!.)
		return
	src.duration = world.time + duration
	var/atom/movable/screen/alert/status_effect/array_turn_back/ATR = linked_alert
	ATR.remember(R)

/datum/status_effect/array_turn_back/on_apply()
	return isreplicator(owner)
