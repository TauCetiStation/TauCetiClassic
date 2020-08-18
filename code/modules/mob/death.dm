//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

//	flick("gibbed-m", animation)
	gibs(loc, viruses, dna)

	dead_mob_list -= src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/proc/dust_process()
	var/icon/I = build_disappear_icon(src)
	var/atom/movable/overlay/animation = null
	animation = new(loc)
	animation.master = src
	flick(I, animation)

	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	emote("scream",,, 1)
	death(1)
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	QDEL_IN(animation, 20)
	QDEL_IN(src, 20)

/mob/proc/dust()
	dust_process()
	new /obj/effect/decal/cleanable/ash(loc)
	dead_mob_list -= src

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
