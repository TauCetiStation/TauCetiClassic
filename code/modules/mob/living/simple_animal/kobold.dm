//kobold
/mob/living/simple_animal/kobold
	name = "kobold"
	desc = "Маленькое существо, похожее на крысу."
	icon = 'icons/mob/mob.dmi'
	icon_state = "kobold_idle"
	icon_living = "kobold_idle"
	icon_dead = "kobold_dead"
	//speak = list("You no take candle!","Ooh, pretty shiny.","Me take?","Where gold here...","Me likey.")
	speak_emote = list("рычит","шипит","пищит")
	emote_hear = list("рычит.","шипит.", "пищит!")
	emote_see = list("подозрительно оглядывается", "чешется", "возится.")
	speak_chance = 15
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	minbodytemp = 250
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

/mob/living/simple_animal/kobold/Life()
	..()
	if(prob(15) && turns_since_move && stat == CONSCIOUS)
		flick("kobold_act",src)

/mob/living/simple_animal/kobold/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(stat == CONSCIOUS)
		flick("kobold_walk",src)
