/mob/living/carbon/monkey/gib()
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

	flick("gibbed-m", animation)
	gibs(loc, viruses, dna)

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/monkey/dust()
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

	spawn(20)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health5"
	stat = DEAD

	if(!gibbed)
		visible_message("<b>The [name]</b> lets out a faint chimper as it collapses and stops moving...")

	update_canmove()

	ticker.mode.check_win()

	return ..(gibbed)
