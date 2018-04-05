/mob/living/carbon/alien/humanoid
	name = "alien"
	icon = 'icons/mob/xenomorph.dmi'
	icon_state = "alien_s"

	pass_flags = PASSTABLE
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	//var/perception = 0 //0 - standart mode, 1 - SEE_TURF mode
	var/praetorians = 2
	//update_icon = 1
	var/alt_icon = 'icons/mob/xenoleap.dmi' //used to switch between the two alien icon files.
	var/leap_on_click = 0

	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 50

	var/neurotoxin_on_click = 0
	var/neurotoxin_delay = 15
	var/neurotoxin_next_shot = 0
	var/last_neurotoxin = 0

	var/last_screech = 0
	var/screech_delay = 900
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 5)


//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	..()

/mob/living/carbon/alien/humanoid/movement_delay()
	return (move_delay_add + config.alien_delay)

///mob/living/carbon/alien/humanoid/bullet_act(obj/item/projectile/Proj) taken care of in living

