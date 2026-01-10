/atom/movable/screen/alert/status_effect/array_turn_back
	name = "Возвращение"
	desc = "Воздействуйте на оболочку, которой управляли до этого."
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


/atom/movable/screen/alert/status_effect/instagib_killed
	name = "Мёртв"
	desc = "Подожди секунду дабы вернуться на арену."
	icon_state = "instagib"

/datum/status_effect/instagib_killed
	id = "instagib_killed"
	duration = 1.2 SECOND
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/instagib_killed

/datum/status_effect/instagib_killed/on_apply()
	. = ..()
	if(!.)
		return

	new /obj/effect/temp_visual/cult/blood(owner.loc)
	owner.Stun(1, TRUE)
	owner.alpha = 55

/datum/status_effect/instagib_killed/on_remove()
	owner.alpha = 255
	owner.apply_status_effect(STATUS_EFFECT_INSTAGIB_SPAWNED)
	return ..()


/atom/movable/screen/alert/status_effect/instagib_spawned
	name = "Возродившийся"
	desc = "Только что возродившиеся игроки не получают и не приносят очков за убийства."
	icon_state = "instagib"

/datum/status_effect/instagib_spawned
	id = "instagib_spawned"
	duration = 1 SECOND
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/instagib_spawned

/datum/status_effect/instagib_spawned/on_apply()
	. = ..()
	if(!.)
		return

	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		var/mutable_appearance/overlay = mutable_appearance('icons/effects/effects.dmi', "bloodsparkles", EXTERNAL_APPEARANCE)
		C.overlays_standing[EXTERNAL_APPEARANCE] = overlay
		C.apply_standing_overlay(EXTERNAL_APPEARANCE)

/datum/status_effect/instagib_spawned/on_remove()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_standing_overlay(EXTERNAL_APPEARANCE)
	return ..()
