
/datum/recipe/pan/humancutlet
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cutlet/human

/datum/recipe/pan/cutlet
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cutlet

/datum/recipe/pan/humanmeatball
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/human
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatball/human

/datum/recipe/pan/meatball
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatball

/datum/recipe/pan/sausage
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball,
		/obj/item/weapon/reagent_containers/food/snacks/rawcutlet,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sausage

/datum/recipe/pan/humanmeatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/human

/datum/recipe/pan/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak
