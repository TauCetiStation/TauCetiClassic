/mob/living/silicon/robot/spawn_gibs()
	robogibs(loc)

/mob/living/silicon/robot/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	var/atom/movable/overlay/animation = new(loc)
	flick(icon('icons/mob/mob.dmi', "gibbed-r"), animation)
	..()
	QDEL_IN(animation, 2 SECONDS)

/mob/living/silicon/robot/dust()
	if(mmi)
		qdel(mmi)	//Delete the MMI first so that it won't go popping out.
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/robot(loc)
	dust_process()

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD

	if(module)
		for(var/obj/item/I in module)
			SEND_SIGNAL(I, COMSIG_HAND_DROP_ITEM, null, src)

	update_canmove()
	if(camera)
		camera.status = 0

	update_sight()
	updateicon()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	sql_report_cyborg_death(src)
	SSStatistics.add_death_stat(src)

	return ..(gibbed)
