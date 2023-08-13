// FOOD RANDOM
/obj/random/foods/food_trash
	name = "Random Trash Pile"
	desc = "This is a random piece of trash."
	icon = 'icons/obj/trash.dmi'
	icon_state = "sosjerky"
/obj/random/foods/food_trash/item_to_spawn()
		return pick(subtypesof(/obj/item/trash))

/obj/random/foods/drink_can
	name = "Random Drink Can Pile"
	desc = "This is a random drink can."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
/obj/random/foods/drink_can/item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/cans))

/obj/random/foods/food_snack
	name = "Random Snack Food Pile"
	desc = "This is a random snack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
/obj/random/foods/food_snack/item_to_spawn()
		return pick(\
						prob(2);/obj/item/weapon/reagent_containers/food/snacks/candy/candybar,\
						prob(2);/obj/item/weapon/reagent_containers/food/drinks/dry_ramen,\
						prob(2);/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen,\
						prob(2);/obj/item/weapon/reagent_containers/food/snacks/chips,\
						prob(2);/obj/item/weapon/reagent_containers/food/snacks/sosjerky,\
						prob(2);/obj/item/weapon/reagent_containers/food/snacks/no_raisin,\
						prob(2);/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie,\
						prob(2);/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers\
					)

/obj/random/foods/ramens
	name = "Random Ramen"
	desc = "This is a random ramen."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "ramen_open"
/obj/random/foods/ramens/item_to_spawn()
		return pick(
						/obj/item/weapon/reagent_containers/food/drinks/dry_ramen,
						/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen,
					)

/obj/random/foods/drink_bottle
	name = "Random Snack Food Pile"
	desc = "This is a random snack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
/obj/random/foods/drink_bottle/item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/bottle))

/obj/random/foods/food_without_garbage
	name = "Random Food Supply without Garbage"
	desc = "This is a random food."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"
/obj/random/foods/food_without_garbage/item_to_spawn()
		return pick(\
						prob(5);/obj/random/foods/food_snack,\
						prob(1);/obj/random/foods/drink_bottle,\
						prob(2);/obj/random/foods/drink_can\
					)

/obj/random/foods/food_with_garbage
	name = "Random Food Supply with Garbage"
	desc = "This is a random food for junkyard."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"
/obj/random/foods/food_with_garbage/item_to_spawn()
		return pick(\
						prob(5);/obj/random/foods/food_snack,\
						prob(1);/obj/random/foods/drink_bottle,\
						prob(2);/obj/random/foods/drink_can,\
						prob(16);/obj/random/foods/food_trash\
					)

/obj/random/foods/donuts
	name = "Random Donut"
	desc = "This is a random donut for donut box."
	icon = 'icons/obj/food.dmi'
	icon_state = "donut_classic"

/obj/random/foods/donuts/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal,
		/obj/item/weapon/reagent_containers/food/snacks/donut/classic,
		/obj/item/weapon/reagent_containers/food/snacks/donut/syndie,
		/obj/item/weapon/reagent_containers/food/snacks/donut/choco,
		/obj/item/weapon/reagent_containers/food/snacks/donut/banana,
		/obj/item/weapon/reagent_containers/food/snacks/donut/berry,
		/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly,
		/obj/item/weapon/reagent_containers/food/snacks/donut/ambrosia,
	)
