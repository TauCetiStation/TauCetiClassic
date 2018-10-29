//robot
/mob/living/simple_animal/robot_rd
	name = "DeT5"
	icon_state = "robot_rd"
	icon_living = "robot_rd"
	icon_dead = "robot_rd_died"
	desc = "The drone on two wheels ... constantly scans everything around you"
	speak = list("Beep", "Beep-beep", "Beeeepski", "One...two...three...more...", "Z-z-z-zero", "One...null...Beep", "Analyzing...", "Successfully", "...this is a joke")
	speak_emote = list("beeps", "rang out")
	emote_hear = list("raises manipulators","twists the scanner")
	emote_see = list("spinning around", "shakes antenna", "turns the indicator on and off")
	speak_chance = 11
	turns_per_move = 1
	see_in_dark = 6
	health = 100
	maxHealth = 100
	response_help  = "is played"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	minbodytemp = 198		//Below -75 Degrees Celcius
	maxbodytemp = 423	//Above 150 Degrees Celcius

/mob/living/simple_animal/robot_rd/DeT5
	name = "DeT5-RD"
	real_name = "DeT5-RD"
	desc = "The drone on two wheels ... constantly scans everything around you"

/mob/living/simple_animal/robot_rd/Life()
	..()
	if(health <= 0) return
	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/mob/living/simple_animal/robot_rd/proc/Die()
	..()
	new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	//respawnable_list += src
	qdel(src)
	return