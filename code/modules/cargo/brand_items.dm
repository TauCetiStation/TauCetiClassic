/obj/item/pizzabox/waffledonk
	desc = "Waffle-Donk inc. brand pizza"

/obj/item/pizzabox/waffledonk/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/carp(src)
	boxtag = "Carp Classic"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/carp
	name = "Carpizza"
	desc = "Is that... a raw carp?"
	icon_state = "pizzacarp"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/carp
	list_reagents = list("plantmatter" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/carp
	name = "Carpizza slice"
	desc = "Is that... a raw carp?"
	icon_state = "pizzacarpslice"

/obj/item/pizzabox/waffledonk/pineapple/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pineapple(src)
	boxtag = "Pineapple Classic"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pineapple
	name = "Pineapple pizza"
	desc = "Ew..."
	icon_state = "pizzapineapple"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/pineapple
	list_reagents = list("plantmatter" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/pineapple
	name = "Pineapple pizza slice"
	desc = "Ew..."
	icon_state = "pizzapineappleslice"



/obj/item/weapon/storage/box/waffle_meal
	name = "Waffle meal"
	desc = "Waffle-Donk inc. brand meal box with a toy!"
	icon_state = "waffle_meal"

/obj/item/weapon/storage/box/waffle_meal/atom_init()
	. = ..()
	new /obj/item/weapon/reagent_containers/food/snacks/fries/cardboard(src)
	new /obj/item/weapon/reagent_containers/food/snacks/fries/cardboard(src)
	new /obj/item/weapon/reagent_containers/food/snacks/tofuburger(src)
	new /obj/item/weapon/reagent_containers/food/snacks/tofuburger(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/sodawater(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/sodawater(src)
	new /obj/random/misc/toy(src)
