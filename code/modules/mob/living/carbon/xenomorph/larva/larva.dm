/mob/living/carbon/xenomorph/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	density = FALSE
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
	name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_verb(/mob/living/carbon/xenomorph/proc/hide)
	alien_list[ALIEN_LARVA] += src
	. = ..()

/mob/living/carbon/xenomorph/larva/Destroy()
	alien_list[ALIEN_LARVA] -= src
	return ..()

//This needs to be fixed
/mob/living/carbon/xenomorph/larva/get_status_tab_items()
	. = ..()

	if(istype(loc, /obj/item/alien_embryo))
		var/obj/item/alien_embryo/E = loc
		. += "Прогресс роста эмбриона: [E.growth_counter]/[FULL_EMBRYO_GROWTH]"
	else
		. += "Прогресс роста: [amount_grown]/[max_grown]"

//If the player wants to become a ghost while in the embryo, then the control of the embryo must be transferred to the AI
/mob/living/carbon/xenomorph/larva/ghostize(can_reenter_corpse = TRUE, bancheck = FALSE)
	if(istype(src.loc, /obj/item/alien_embryo))
		var/obj/item/alien_embryo/E = loc
		E.controlled_by_ai = TRUE
	return ..()

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
