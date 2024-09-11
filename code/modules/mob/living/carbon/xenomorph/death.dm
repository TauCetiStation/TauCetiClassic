/mob/living/carbon/xenomorph/facehugger/death(gibbed)
	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	..(gibbed)

	var/obj/item/clothing/mask/facehugger/F = new /obj/item/clothing/mask/facehugger(loc)
	F.Die()
	qdel(src)

/mob/living/carbon/xenomorph/larva/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD
	icon_state = "larva_dead"

	if(!gibbed)
		update_canmove()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	alive_mob_list -= src

	return ..(gibbed)

/mob/living/carbon/xenomorph/humanoid/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD

	if(!gibbed)
		playsound(src, 'sound/voice/xenomorph/death_1.ogg', VOL_EFFECTS_MASTER)
		visible_message("<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw...")
		update_canmove()
		update_icons()

	tod = worldtime2text() //weasellos time of death patch
	if(mind) 	mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)

/mob/living/carbon/xenomorph/spawn_gibs()
	xgibs(loc)

/mob/living/carbon/xenomorph/gib()
	var/atom/movable/overlay/animation = new(loc)
	flick(icon('icons/mob/mob.dmi', "gibbed-a"), animation)
	..()
	QDEL_IN(animation, 2 SECONDS)

/mob/living/carbon/xenomorph/dust()
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/xeno/burned(loc)
	dust_process()
