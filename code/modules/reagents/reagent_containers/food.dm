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
