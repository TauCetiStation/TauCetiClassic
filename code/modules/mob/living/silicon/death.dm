/mob/living/silicon/gib()
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

//	flick("gibbed-r", animation)
	robogibs(loc, viruses)

	dead_mob_list -= src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/silicon/dust()
	var/atom/movable/overlay/animation = null
	var/icon/I = new(getFlatIcon(src),,,1)
	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	death(1)
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	var/icon/T = icon('icons/effects/effects.dmi',"disappear")
	T.BecomeAlphaMask()

	I.MapColors(rgb(45,45,45), rgb(70,70,70), rgb(30,30,30), rgb(0,0,0))
	I.AddAlphaMask(T)

	animation = new(loc)
	animation.master = src
	flick(I, animation)

	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/robot(loc)
	dead_mob_list -= src

	spawn(20)
		if(animation)	qdel(animation)
		if(src)			qdel(src)