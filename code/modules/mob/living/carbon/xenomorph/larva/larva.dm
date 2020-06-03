/mob/living/carbon/xenomorph/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
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
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/xenomorph/larva/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	. = ..()

//This needs to be fixed
/mob/living/carbon/xenomorph/larva/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")

/mob/living/carbon/xenomorph/larva/toggle_throw_mode()
	return

/mob/living/carbon/xenomorph/larva/throw_mode_on()
	return

/mob/living/carbon/xenomorph/larva/throw_mode_off()
	return

/mob/living/carbon/xenomorph/larva/throw_item(atom/target)
	return

/mob/living/carbon/xenomorph/larva/start_pulling(atom/movable/AM)//Prevents mouse from pulling things
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return

/mob/living/carbon/xenomorph/larva/swap_hand()
	return

/mob/living/carbon/xenomorph/larva/movement_delay()
	return (move_delay_add + config.alien_delay - 1)

/mob/living/carbon/xenomorph/larva/can_pickup(obj/O)
	return FALSE

/mob/living/carbon/xenomorph/facehugger/is_usable_head(targetzone = null)
	return TRUE

/mob/living/carbon/xenomorph/facehugger/is_usable_arm(targetzone = null)
	return FALSE

/mob/living/carbon/xenomorph/facehugger/is_usable_leg(targetzone = null)
	return FALSE
