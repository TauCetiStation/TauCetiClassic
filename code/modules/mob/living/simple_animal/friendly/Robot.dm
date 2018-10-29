//Robot
/mob/living/simple_animal/robot_rd
	name = "Robot_RD"
	desc = "A robot looking at everything around has an antenna on top"
	icon_state = "robot_rd"
	icon_living = "robot_rd"
	icon_dead = "robot_rd_died"
	speak = list("Beep","Z-z-z-zero","One...null...Beep","Analyzing", "Successfully")
	speak_emote = list("clicks", "sparkles")
	emote_hear = list("raises manipulators","twists the scanner")
	emote_see = list("spinning around", "shakes antenna", "turns the indicator on and off")
	speak_chance = 1
	turns_per_move = 5
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
	desc = "A robot looking at everything around has an antenna on top"