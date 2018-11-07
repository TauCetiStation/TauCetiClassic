
///-----------------------------------------------------//
///														//
///						Food.							//
///	What's food? Food is items that we usually drink/eat//
///	Easy, right? Well, there's a lot of food types,		//
///			and food has lots of variables.				//
///				Types of food:							//
///					*Snacks								//
///					*Drinks								//
///					*Condiments							//
///														//
///-----------------------------------------------------//

/obj/item/weapon/reagent_containers/food

	name = "consumable object"

	icon = 'icons/obj/food_and_drinks/snacks.dmi'
	lefthand_file = 'icons/mob/inhands/food_n_drinks/food_n_drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/food_n_drinks/food_n_drinks_righthand.dmi'

	possible_transfer_amounts = null

	volume = 50//Sets the default container amount for all food items.

	var/taste = TRUE//whether you can taste eating from this
	var/filling_color = "#FFFFFF" //Used by sandwiches.

/obj/item/weapon/reagent_containers/food/atom_init()
	. = ..()
	pixel_x = rand(-6.0, 6)//Randomizes postion
	pixel_y = rand(-6.0, 6)








