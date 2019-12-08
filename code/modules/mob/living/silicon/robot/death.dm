/mob/living/silicon/robot/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	var/atom/movable/overlay/animation = null
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("gibbed-r", animation)
	robogibs(loc, viruses)

	alive_mob_list -= src
	dead_mob_list -= src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/silicon/robot/dust()
	var/atom/movable/overlay/animation = null
	var/icon/I = getFlatIcon(src)
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
	animation.icon = I
	animation.master = src

	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)		qdel(mmi)	//Delete the MMI first so that it won't go popping out.
	dead_mob_list -= src

	spawn(20)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD
	update_canmove()
	if(camera)
		camera.status = 0

	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	updateicon()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	sql_report_cyborg_death(src)

	return ..(gibbed)
