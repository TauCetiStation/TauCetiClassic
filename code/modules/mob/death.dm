/mob/proc/spawn_gibs()
	gibs(loc, dna)

//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	death(1)

	spawn_gibs()

	qdel(src)

/mob/proc/dust_process()
	var/icon/I = build_disappear_icon(src, lying ? -lying_current : 0)
	var/atom/movable/overlay/animation = new(loc)
	animation.transform = transform
	flick(I, animation)

	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	emote("scream")
	death(1)
	qdel(src)

	QDEL_IN(animation, 2 SECONDS)

/mob/proc/dust()
	new /obj/effect/decal/cleanable/ash(loc)
	dust_process()
	

/mob/proc/death(gibbed)
	SEND_SIGNAL(src, COMSIG_MOB_DIED, gibbed)

	//Quick fix for corpses kept propped up in chairs. ~Z
	drop_r_hand()
	drop_l_hand()
	//End of fix.

	timeofdeath = world.time

	alive_mob_list -= src
	dead_mob_list += src
	clear_fullscreens()
	setDrugginess(0)

	for(var/mob/M as anything in remote_hearers)
		remove_remote_hearer(M)

	for(var/mob/M as anything in remote_hearing)
		M.remove_remote_hearer(src)
