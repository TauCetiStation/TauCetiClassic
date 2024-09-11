//Foxxy
/mob/living/simple_animal/fox
	name = "fox"
	desc = "Это лиса. Интересно, что она говорит?"
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Акк-акк","Ак-ак-ак-акавуууу!","Хекь","Авууу","Тсиф!")
	speak_emote = list("лает")
	emote_hear = list("лает")
	emote_see = list("облизывается", "принюхивается")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	w_class = SIZE_BIG
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	has_head = TRUE
	has_leg = TRUE

//Captain fox
ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/fox/Renault, chief_animal_list)
/mob/living/simple_animal/fox/Renault
	name = "Renault"
	desc = "Верный лис капитана. Интересно, что он говорит?"
