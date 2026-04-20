/obj/item/weapon/reagent_containers/blood
	name = "bloodpack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	item_state_world = "empty_w"
	item_state_inventory = "empty"
	volume = 200

	var/blood_type = null

/obj/item/weapon/reagent_containers/blood/atom_init()
	. = ..()
	if(blood_type != null)
		reagents.add_reagent("blood", 200, list("blood_type" = blood_type))
	update_icon()

/obj/item/weapon/reagent_containers/blood/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/blood/update_icon()
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(0 to 9)			
			icon_state = "empty"
			item_state_inventory = "empty"
			item_state_world = "empty_w"
		if(10 to 50) 		
			icon_state = "half"
			item_state_inventory = "half"
			item_state_world = "half_w"
		if(51 to INFINITY)	
			icon_state = "full"
			item_state_inventory = "full"
			item_state_world = "full_w"
	update_world_icon()

/obj/item/weapon/reagent_containers/blood/APlus
	name = "bloodpack A(II) Rh+"
	blood_type = BLOOD_A_PLUS

/obj/item/weapon/reagent_containers/blood/AMinus
	name = "bloodpack A(II) Rh-"
	blood_type = BLOOD_A_MINUS

/obj/item/weapon/reagent_containers/blood/BPlus
	name = "bloodpack B(III) Rh+"
	blood_type = BLOOD_B_PLUS

/obj/item/weapon/reagent_containers/blood/BMinus
	name = "bloodpack B(III) Rh-"
	blood_type = BLOOD_B_MINUS

/obj/item/weapon/reagent_containers/blood/OPlus
	name = "bloodpack O(I) Rh+"
	blood_type = BLOOD_O_PLUS

/obj/item/weapon/reagent_containers/blood/OMinus
	name = "bloodpack O(I) Rh-"
	blood_type = BLOOD_O_MINUS

/obj/item/weapon/reagent_containers/blood/empty
	name = "empty bloodpack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "empty"
	item_state_world = "empty_w"
