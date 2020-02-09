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
	var/icon/I = new(getFlatIcon(src),,,1)
	var/atom/movable/overlay/animation = null
	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	emote("scream",,, 1)
	death(1)
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	var/W = I.Width()
	var/H = I.Height()
	var/icon/T = icon('icons/effects/effects.dmi',"disappear")
	if(W != world.icon_size || H != world.icon_size)
		T.Scale(W, H)
	T.BecomeAlphaMask()

	I.MapColors(rgb(45,45,45), rgb(70,70,70), rgb(30,30,30), rgb(0,0,0))
	I.AddAlphaMask(T)

	animation = new(loc)
	animation.master = src
	sleep(1) //try to fix invisible flick animation
	flick(I, animation)

	spawn(20)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/proc/dust()
	dust_process()
	new /obj/effect/decal/cleanable/ash(loc)
	dead_mob_list -= src

/mob/proc/death(gibbed)
	//Quick fix for corpses kept propped up in chairs. ~Z
	drop_r_hand()
	drop_l_hand()
	//End of fix.

	timeofdeath = world.time

	alive_mob_list -= src
	dead_mob_list += src
	clear_fullscreens()
