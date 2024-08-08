//Wall-E
ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/walle, chief_animal_list)
/mob/living/simple_animal/walle
	name = "Wall-E"
	desc = "Робот, который ищет ЕВУ."
	icon_state = "walle"
	icon_living = "walle"
	icon_dead = "walle_dead"
	speak = list("Бип-буп","Ева? Ева-а-а!","Бзз.")
	speak_emote = list("гудит", "пищит")
	emote_hear = list("гудит", "пищит")
	emote_see = list("перерабатывает мусор", "пользуется солнечной батареей")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	butcher_results = list(/obj/item/stack/sheet/refined_scrap = 1)

/mob/living/simple_animal/walle/death()
	..()
	new /obj/effect/decal/cleanable/blood/gibs/robot(loc)// drob blood robots
	new /obj/effect/gibspawner/robot(loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
