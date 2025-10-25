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

/obj/random/foods/gummybear
	name = "Random Gummybear"
	desc = "This is a random gummybear."
	icon = 'icons/obj/food.dmi'
	icon_state = "gbear"

/obj/random/foods/gummybear/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf,
	)

/obj/random/foods/gummyworm
	name = "Random Gummyworm"
	desc = "This is a random gummyworm."
	icon = 'icons/obj/food.dmi'
	icon_state = "gworm"

/obj/random/foods/gummyworm/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/pink,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf,
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/rainbow,
	)

/obj/random/foods/jellybean
	name = "Random Jellybean"
	desc = "This is a random jellybean."
	icon = 'icons/obj/food.dmi'
	icon_state = "jbean"

/obj/random/foods/jellybean/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee,
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf,
	)

/obj/random/foods/candies
	name = "Random Candy"
	desc = "This is a random candy for a candy jar."
	icon = 'icons/obj/food.dmi'
	icon_state = "candy1"

/obj/random/foods/candies/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/candy/taffy,
		/obj/random/foods/gummybear,
		/obj/random/foods/gummyworm,
		/obj/random/foods/jellybean,
		/obj/item/weapon/reagent_containers/food/snacks/candy/candycane,
		/obj/item/weapon/reagent_containers/food/snacks/candy/lollipop,
	)


/obj/random/foods/egg
	name = "Random Colored Egg"
	desc = "This is a random colored egg."
	icon = 'icons/obj/food.dmi'
	icon_state = "egg-rainbow"

/obj/random/foods/egg/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/egg/blue,
		/obj/item/weapon/reagent_containers/food/snacks/egg/green,
		/obj/item/weapon/reagent_containers/food/snacks/egg/orange,
		/obj/item/weapon/reagent_containers/food/snacks/egg/purple,
		/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow,
		/obj/item/weapon/reagent_containers/food/snacks/egg/red,
		/obj/item/weapon/reagent_containers/food/snacks/egg/yellow,
	)

/obj/random/foods/boiledegg
	name = "Random Boiled Colored Egg"
	desc = "This is a random boiled colored egg."
	icon = 'icons/obj/food.dmi'
	icon_state = "egg-rainbow"

/obj/random/foods/boiledegg/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/blue,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/green,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/orange,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/purple,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/rainbow,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/red,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg/yellow,
	)
