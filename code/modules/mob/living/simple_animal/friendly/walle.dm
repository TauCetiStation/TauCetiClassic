//Wall-E
ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/walle, chief_animal_list)
/mob/living/simple_animal/walle
	name = "Wall-E"
	desc = "The robot which looks for EVA."
	icon_state = "walle"
	icon_living = "walle"
	icon_dead = "walle_dead"
	speak = list("Beep-Boop","Eva? Evaaa!","Buzz.")
	speak_emote = list("rustles", "smokes")
	emote_hear = list("pings")
	emote_see = list("processes garbage", "has got the solar battery")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
