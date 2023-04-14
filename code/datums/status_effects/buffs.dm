/atom/movable/screen/alert/status_effect/swarm_gift
	name = "Swarm's Gift"
	desc = "The Swarm gifts you with increased efficency, as well as muffled disintegration noises. Prosper and multiply!"
	icon_state = "swarm_gift"

/atom/movable/screen/alert/status_effect/swarm_gift/Click()
	if(!mob_viewer)
		return
	if(!mob_viewer.ckey)
		return
	if(mob_viewer.incapacitated())
		return
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[mob_viewer.ckey]
	if(!RAI)
		return
	if(RAI.next_music_start >= world.time)
		return
	RAI.next_music_start = world.time + REPLICATOR_MUSIC_LENGTH

	mob_viewer.playsound_local(null, 'sound/music/storm_resurrection.ogg', VOL_MUSIC, null, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)


/datum/status_effect/swarm_gift
	id = "swarm_gift"
	alert_type = /atom/movable/screen/alert/status_effect/swarm_gift

/datum/status_effect/swarm_gift/on_creation(mob/living/new_owner, duration)
	. = ..()
	if(!.)
		return
	src.duration = world.time + duration

/datum/status_effect/swarm_gift/on_apply()
	owner.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	return isreplicator(owner)

/datum/status_effect/swarm_gift/on_remove()
	owner.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)
	return isreplicator(owner)
