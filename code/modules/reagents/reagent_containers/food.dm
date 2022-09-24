////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Sets the default container amount for all food items.
	var/filling_color = "#ffffff" //Used by sandwiches.
	var/taste = TRUE//whether you can taste eating from this

/obj/item/weapon/reagent_containers/food/atom_init()
	. = ..()
	pixel_x = rand(-10.0, 10) //Randomizes postion
	pixel_y = rand(-10.0, 10)

	RegisterSignal(src, list(COMSIG_ATOM_START_PULL), .proc/tajaran_effect)

/obj/item/weapon/reagent_containers/food/proc/tajaran_effect(obj/item, mob/M)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/check_cloth = 100 - H.getarmor(null, "bio")
	if(H.species.name == TAJARAN)
		if(prob(check_cloth))
			ADD_TRAIT(src, TRAIT_TAJARAN_HAIR, GENERIC_TRAIT)

/obj/item/weapon/reagent_containers/food/pickup(mob/living/user)
	. = ..()
	tajaran_effect(user)

/obj/item/weapon/reagent_containers/food/Destroy()
	UnregisterSignal(src, list(COMSIG_ATOM_START_PULL))
	REMOVE_TRAIT(src, TRAIT_TAJARAN_HAIR, GENERIC_TRAIT)

	return ..()
