//robot
/mob/living/simple_animal/det5
	name = "DET5"
	icon_state = "robot_rd"
	icon_living = "robot_rd"
	icon_dead = "robot_rd_died"
	desc = "Its a robot with shiny wheels. Sometimes sparks fly out of its hull."

	speak = list("Beep", "Beep-beep", "Beeeepsky",
				 "One...two...three...more...",
				 "Z-z-z-zero", "One...null...Beep",
				 "Analyzing...", "Successfully",
				 "...this is a joke", "La la la...beep",
				 "Boom...", "Not enough time",
				 "Science time", "ED-209 protect me")

	speak_emote = list("beeps", "rang out")
	emote_hear = list("raises manipulators", "twists the scanner")
	emote_see = list("spinning around", "turns the indicator on and off")
	speak_chance = 15
	turns_per_move = 1
	see_in_dark = 6
	health = 70
	maxHealth = 70
	response_help  = "is played"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	minbodytemp = 198	// Below -75 Degrees Celcius
	maxbodytemp = 423	// Above 150 Degrees Celcius
	var/emagged = 0    // Trigger EMAG used
	var/cont = 0	// Used command
	var/targetexplode = 0	// Trigger explode
	var/explosion_power = 1

/mob/living/simple_animal/det5/Life()
	..()
	if(health <= 0)
		return
	// spark for no reason
	cont = 0	// Clear
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/mob/living/simple_animal/det5/death()
	..()
	visible_message("<b>[src]</b> rang out 'd-d-d-data received...d-d-d-destruction'")
	new /obj/item/stack/sheet/mineral/diamond(loc, 2)// drop diamond (2)
	new /obj/item/stack/sheet/mineral/silver(loc, 4)// drop silver (4)
	new /obj/effect/decal/cleanable/blood/gibs/robot(loc)// drob blood robots
	new /obj/effect/gibspawner/robot(loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	//respawnable_list += src
	qdel(src)
	return

/mob/living/simple_animal/det5/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)	// Trigger EMAG
		user.SetNextMove(CLICK_CD_MELEE)
		Emag(user)
	if (istype(W, /obj/item/device/det5controll))	// Trigger Controller
		user.SetNextMove(CLICK_CD_MELEE)
		det5controll(user)
	else
		..()

/mob/living/simple_animal/det5/HasProximity(atom/movable/AM)	// Trigger move
	if(targetexplode == 1)
		if(istype(AM, /mob/living/carbon))
			targetexplode = 0
			explode()

/mob/living/simple_animal/det5/proc/explode()	// explode
	visible_message("<b>[src]</b> rang out 'The #xplosi@n is prep@red, @-a-activate'")
	sleep(35)
	explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1)
	death()

mob/living/simple_animal/det5/proc/Emag(user)	// used EMAG
	if(!emagged)
		emagged = 1
		visible_message("<b>[src]</b> rang out 'B-b-b-broken pro#oco%s %%ctivated'")

/mob/living/simple_animal/det5/proc/det5controll(user)	// Used Controller (Input command)
	if(health <=0)
		return
	else
		if(emagged != 1)
			cont = input("Enter the command. 1-Moving stop/start. 2-Speak stop/start", , "Cancel")
		else
			cont = input("Enter the command. 1-Moving stop/start. 2-Speak stop/start. 3-Explode (50s). 4-Explode (targetmove)", , "Cancel")
		if(cont == "1")
			if(turns_per_move == 1)
				turns_per_move = 100
				visible_message("<b>[src]</b> rang out 'Movement stopped'")
			else
				turns_per_move = 1
				visible_message("<b>[src]</b> rang out 'Motion activated'")
		if(cont == "2")
			if(speak_chance == 15)
				speak_chance = 0
				visible_message("<b>[src]</b> rang out 'Talk stopped'")
			else
				speak_chance = 15
				visible_message("<b>[src]</b> rang out 'Talk activated'")
		if(cont == "3")
			if(emagged != 1)
				visible_message("<b>[src]</b> rang out 'Unknown command'")
			else
				visible_message("<b>[src]</b> rang out 'Self-d#str@ct pr@t@col a-a-a-activated'")
				spawn (500)
					src.explode()
		if(cont == "4")
			if(emagged != 1)
				visible_message("<b>[src]</b> rang out 'Unknown command'")
			else
				visible_message("<b>[src]</b> rang out 'Self-d##struct m@de with t@rget @ctiv@t#d'")
				targetexplode = 1