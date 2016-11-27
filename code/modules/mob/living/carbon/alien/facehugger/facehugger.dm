var/const/MIN_IMPREGNATION_TIME = 100 //time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 150

/mob/living/carbon/alien/facehugger
	name = "alien facehugger"
	desc = "It has some sort of a tube at the end of its tail."
	real_name = "alien facehugger"

	icon_state = "facehugger"
	pass_flags = PASSTABLE | PASSMOB

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	density = 0
	small = 1

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/clothing/head/head = null			//
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/facehugger/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien facehugger")
		name = "alien facehugger ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	a_intent = "grab"
	..()

/mob/living/carbon/alien/facehugger/adjustToxLoss(amount)
	..(amount)

/mob/living/carbon/alien/facehugger/start_pulling(atom/movable/AM)//Prevents mouse from pulling things
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return

/mob/living/carbon/alien/facehugger/swap_hand()
	return

/mob/living/carbon/alien/facehugger/movement_delay()
	var/tally = 0
	if (istype(src, /mob/living/carbon/alien/facehugger/)) //just in case
		tally = -1
	return (tally + move_delay_add + config.alien_delay)
