/mob/living/carbon/alien/facehugger/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health6"
	stat = DEAD
	icon_state = "facehugger_dead"

	if(!gibbed)
		update_canmove()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	alive_mob_list -= src

	return ..(gibbed)

/mob/living/carbon/alien/larva/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health6"
	stat = DEAD
	icon_state = "larva_dead"

	if(!gibbed)
		update_canmove()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	alive_mob_list -= src

	return ..(gibbed)

/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health6"
	stat = DEAD

	if(!gibbed)
		playsound(src, 'sound/voice/xenomorph/death_1.ogg', VOL_EFFECTS_MASTER)
		for(var/mob/O in viewers(src, null))
			O.show_message("<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw...", 1)
		update_canmove()
		update_icons()

	tod = worldtime2text() //weasellos time of death patch
	if(mind) 	mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)

/mob/living/carbon/alien/humanoid/praetorian/death()
	..()
	praetorians = (praetorians+1)

/mob/living/carbon/alien/gib()
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

	flick("gibbed-a", animation)
	xgibs(loc, viruses)
	dead_mob_list -= src

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/alien/dust()
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
	new /obj/effect/decal/remains/xeno(loc)
	dead_mob_list -= src

	spawn(20)
		if(animation)	qdel(animation)
		if(src)			qdel(src)
