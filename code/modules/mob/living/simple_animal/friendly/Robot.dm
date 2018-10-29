//Robot
/mob/living/simple_animal/robot_rd
	icon_state = "robot_rd"
	icon_living = "robot_rd"
	icon_dead = "robot_rd_died"
	speak = list("Beep", "Beep-beep", "Beeeepski", "One...two...three...more...", "Z-z-z-zero", "One...null...Beep", "Analyzing...", "Successfully", "...this is a joke", "This platform was created specifically to merge with the surrounding world of organics. I can build contacts and put down my guard ... until my hour comes ... a mistake, said out loud")
	speak_emote = list("beeps", "rang out")
	emote_hear = list("raises manipulators","twists the scanner")
	emote_see = list("spinning around", "shakes antenna", "turns the indicator on and off")
	speak_chance = 11
	turns_per_move = 4
	see_in_dark = 6
	response_help  = "is played"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	min_oxy = 0 //Require atleast 0kPA oxygen
	minbodytemp = 198		//Below -75 Degrees Celcius
	maxbodytemp = 423	//Above 150 Degrees Celcius
	flags = list(
	 IS_SYNTHETIC = TRUE
	,NO_BREATHE = TRUE
	)
/mob/living/simple_animal/robot_rd/DeT5
	name = "DeT5-RD"
	real_name = "DeT5-RD"
	desc = "A flying drone with two manipulators, the violet eye had a liquid inside, in which a single eye was moving exploring everything around. He is hiding something ...."
/mob/living/simple_animal/robot_rd/DeT5/Life()
	..()
	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()