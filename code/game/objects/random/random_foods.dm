// FOOD RANDOM
/obj/random/food_trash
	name = "Random Trash Pile"
	desc = "This is a random piece of trash."
	icon = 'icons/obj/trash.dmi'
	icon_state = "sosjerky"
	item_to_spawn()
		return pick(subtypesof(/obj/item/trash))

/obj/random/drink_can
	name = "Random Drink Can Pile"
	desc = "This is a random drink can."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/cans))

/obj/random/food_snack
	name = "Random Snack Food Pile"
	desc = "This is a random snack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
	item_to_spawn()
		return pick(prob(2);/obj/item/weapon/reagent_containers/food/snacks/candy,\
					prob(2);/obj/item/weapon/reagent_containers/food/drinks/dry_ramen,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/chips,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/sosjerky,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/no_raisin,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers)

/obj/random/drink_bottle
	name = "Random Snack Food Pile"
	desc = "This is a random snack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/bottle))

/obj/random/food_without_garbage
	name = "Random Food Supply with Garbage"
	desc = "This is a random food for junkyard."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"
	item_to_spawn()
		return pick(prob(5);/obj/random/food_snack,\
					prob(1);/obj/random/drink_bottle,\
					prob(2);/obj/random/drink_can)

/obj/random/food_with_garbage
	name = "Random Food Supply with Garbage"
	desc = "This is a random food for junkyard."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"
	item_to_spawn()
		return pick(prob(5);/obj/random/food_snack,\
					prob(1);/obj/random/drink_bottle,\
					prob(2);/obj/random/drink_can,\
					prob(16);/obj/random/food_trash)