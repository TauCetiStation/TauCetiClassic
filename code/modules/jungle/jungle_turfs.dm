
/turf/unsimulated/jungle
	var/bushes_spawn = 1
	var/plants_spawn = 1
	name = "wet grass"
	desc = "Thick, long wet grass."
	icon = 'code/modules/jungle/jungle.dmi'
	icon_state = "grass1"
	var/icon_spawn_state = "grass1"

/turf/unsimulated/jungle/atom_init()
	. = ..()
	icon_state = icon_spawn_state

	if(plants_spawn && prob(40))
		if(prob(90))
			var/image/I
			if(prob(35))
				I = image('code/modules/jungle/jungle.dmi',"plant[rand(1,7)]")
			else
				if(prob(30))
					I = image('icons/obj/flora/ausflora.dmi',"reedbush_[rand(1,4)]")
				else if(prob(33))
					I = image('icons/obj/flora/ausflora.dmi',"leafybush_[rand(1,3)]")
				else if(prob(50))
					I = image('icons/obj/flora/ausflora.dmi',"fernybush_[rand(1,3)]")
				else
					I = image('icons/obj/flora/ausflora.dmi',"stalkybush_[rand(1,3)]")
			I.pixel_x = rand(-6,6)
			I.pixel_y = rand(-6,6)
			add_overlay(I)
		else
			var/obj/structure/jungle_plant/J = new(src)
			J.pixel_x = rand(-6,6)
			J.pixel_y = rand(-6,6)
	if(bushes_spawn && prob(90))
		new /obj/structure/bush(src)

/turf/unsimulated/jungle/clear
	bushes_spawn = 0
	plants_spawn = 0
	icon_state = "grass_clear"
	icon_spawn_state = "grass3"

/turf/unsimulated/jungle/path
	bushes_spawn = 0
	name = "wet grass"
	desc = "Thick, long wet grass."
	icon = 'code/modules/jungle/jungle.dmi'
	icon_state = "grass_path"
	icon_spawn_state = "grass2"

/turf/unsimulated/jungle/path/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/unsimulated/jungle/path/atom_init_late()
	for(var/obj/structure/bush/B in src)
		qdel(B)

/turf/unsimulated/jungle/proc/Spread(probability, prob_loss = 50)
	if(probability <= 0)
		return

	//world << "<span class='notice'>Spread([probability])</span>"
	for(var/turf/unsimulated/jungle/J in orange(1, src))
		if(!J.bushes_spawn)
			continue

		var/turf/unsimulated/jungle/P = null
		if(J.type == src.type)
			P = J
		else
			P = new src.type(J)

		if(P && prob(probability))
			P.Spread(probability - prob_loss)

/turf/unsimulated/jungle/impenetrable
	bushes_spawn = 0
	icon_state = "grass_impenetrable"
	icon_spawn_state = "grass1"

/turf/unsimulated/jungle/impenetrable/atom_init()
	. = ..()
	var/obj/structure/bush/B = new(src)
	B.indestructable = 1

//copy paste from asteroid mineral turfs
/turf/unsimulated/jungle/rock
	bushes_spawn = 0
	plants_spawn = 0
	density = 1
	name = "rock wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	icon_spawn_state = "rock"

/turf/unsimulated/jungle/rock/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/unsimulated/jungle/rock/atom_init_late()
	var/turf/T
	if(!istype(get_step(src, NORTH), /turf/unsimulated/jungle/rock) && !istype(get_step(src, NORTH), /turf/unsimulated/wall))
		T = get_step(src, NORTH)
		if (T)
			T.add_overlay(image('icons/turf/walls.dmi', "rock_side_s"))
	if(!istype(get_step(src, SOUTH), /turf/unsimulated/jungle/rock) && !istype(get_step(src, SOUTH), /turf/unsimulated/wall))
		T = get_step(src, SOUTH)
		if (T)
			T.add_overlay(image('icons/turf/walls.dmi', "rock_side_n", layer=6))
	if(!istype(get_step(src, EAST), /turf/unsimulated/jungle/rock) && !istype(get_step(src, EAST), /turf/unsimulated/wall))
		T = get_step(src, EAST)
		if (T)
			T.add_overlay(image('icons/turf/walls.dmi', "rock_side_w", layer=6))
	if(!istype(get_step(src, WEST), /turf/unsimulated/jungle/rock) && !istype(get_step(src, WEST), /turf/unsimulated/wall))
		T = get_step(src, WEST)
		if (T)
			T.add_overlay(image('icons/turf/walls.dmi', "rock_side_e", layer=6))

/turf/unsimulated/jungle/water
	bushes_spawn = 0
	name = "murky water"
	desc = "Thick, murky water."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	icon_spawn_state = "water"

/turf/unsimulated/jungle/water/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/unsimulated/jungle/water/atom_init_late()
	for(var/obj/structure/bush/B in src)
		qdel(B)

/turf/unsimulated/jungle/water/Entered(atom/movable/O)
	..()
	if(istype(O, /mob/living))
		var/mob/living/M = O
		//slip in the murky water if we try to run through it
		if(prob(10 + (M.m_intent == "run" ? 40 : 0)))
			M.slip(2, src)

		//piranhas - 25% chance to be an omnipresent risk, although they do practically no damage
		if(prob(25))
			to_chat(M, "<span class='notice'>You feel something slithering around your legs.</span>")
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/unsimulated/jungle/water))
						to_chat(M, pick("<span class='warning'>Something sharp bites you!</span>","<span class='warning'>Sharp teeth grab hold of you!</span>","<span class='warning'>You feel something take a chunk out of your leg!</span>"))
						M.apply_damage(rand(0, 1), BRUTE, null, null, DAM_SHARP)
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/unsimulated/jungle/water))
						to_chat(M, pick("<span class='warning'>Something sharp bites you!</span>","<span class='warning'>Sharp teeth grab hold of you!</span>","<span class='warning'>You feel something take a chunk out of your leg!</span>"))
						M.apply_damage(rand(0, 1), BRUTE, null, null, DAM_SHARP)
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/unsimulated/jungle/water))
						to_chat(M, pick("<span class='warning'>Something sharp bites you!</span>","<span class='warning'>Sharp teeth grab hold of you!</span>","<span class='warning'>You feel something take a chunk out of your leg!</span>"))
						M.apply_damage(rand(0, 1), BRUTE, null, null, DAM_SHARP)
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/unsimulated/jungle/water))
						to_chat(M, pick("<span class='warning'>Something sharp bites you!</span>","<span class='warning'>Sharp teeth grab hold of you!</span>","<span class='warning'>You feel something take a chunk out of your leg!</span>"))
						M.apply_damage(rand(0, 1), BRUTE, null, null, DAM_SHARP)

/turf/unsimulated/jungle/water/deep
	plants_spawn = 0
	density = 1
	icon_state = "water2"
	icon_spawn_state = "water2"

/turf/unsimulated/jungle/temple_wall
	name = "temple wall"
	desc = ""
	density = 1
	icon = 'icons/turf/walls.dmi'
	icon_state = "phoron0"
	var/mineral = "phoron"
