/mob/living/simple_animal/centipede
	name = "Centipede"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	desc = "A long centipede, a chitinous body shimmers, her movements are quick and she eagerly looks at your garbage"

	speak_emote = list("chic-chic")
	emote_hear = list("screeching")
	emote_see = list("screeching")
	speak_chance = 10
	turns_per_move = 3
	see_in_dark = 6
	health = 70
	maxHealth = 70
	response_help  = "is played"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	minbodytemp = 198	// Below -75 Degrees Celcius
	maxbodytemp = 423	// Above 150 Degrees Celcius
	var/area/awaymission/junkyard/area_spawn

/mob/living/simple_animal/centipede/atom_init()
	.=..()
	if(istype(get_area(src.loc), /area/awaymission/junkyard))
		area_spawn = get_area(src.loc)
		area_spawn.amount_of_centipedes += 1

/mob/living/simple_animal/centipede/Destroy()
	area_spawn.amount_of_centipedes -= 1
	return ..()

/mob/living/simple_animal/centipede/death()
	..()
	new /obj/effect/gibspawner/xeno(src)
	qdel(src)

/mob/living/simple_animal/centipede/Life()
	..()
	if(health <= 0)
		return
	for(var/obj/item/weapon/scrap_lump/scrap in oview(src, 3))
		walk_to(src, scrap.loc,0,2)
		qdel(scrap)
		break
