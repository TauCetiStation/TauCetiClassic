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


//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust()
	var/atom/movable/overlay/animation = null
	var/icon/I = new(getFlatIcon(src),,,1)
	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	death(1)
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	var/W = I.Width()
	var/H = I.Height()
	var/icon/T = icon('icons/effects/effects.dmi',"disappear")
	if(W != 32 || H != 32)
		T.Scale(W, H)
	T.BecomeAlphaMask()

	I.MapColors(rgb(45,45,45), rgb(70,70,70), rgb(30,30,30), rgb(0,0,0))
	I.AddAlphaMask(T)

	animation = new(loc)
	animation.master = src
	flick(I, animation)

	new /obj/effect/decal/cleanable/ash(loc)
	dead_mob_list -= src

	spawn(20)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/proc/death(gibbed)

	//Quick fix for corpses kept propped up in chairs. ~Z
	drop_r_hand()
	drop_l_hand()
	//End of fix.

	timeofdeath = world.time

	alive_mob_list -= src
	dead_mob_list += src
	clear_fullscreens()
	return ..(gibbed)
