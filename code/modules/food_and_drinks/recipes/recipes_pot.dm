
/datum/recipe/pot/meatballsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
		/obj/item/weapon/reagent_containers/food/snacks/cleanedpotato
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/meatballsoup

/datum/recipe/pot/vegetablesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/cleanedpotato
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/vegetablesoup

/datum/recipe/pot/nettlesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/grown/nettle,
		/obj/item/weapon/reagent_containers/food/snacks/cleanedpotato
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/nettlesoup

/datum/recipe/pot/wishsoup
	reagents = list("water" = 20)
	result= /obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup

/datum/recipe/pot/hotchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/hotchili

/datum/recipe/pot/coldchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/coldchili

/datum/recipe/pot/bloodsoup
	reagents = list("blood" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/bloodsoup

/datum/recipe/pot/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/slimesoup

/datum/recipe/pot/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/ore/clown,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/clownstears

/datum/recipe/pot/boiledslimeextract
	reagents = list("water" = 10)
	items = list(
		/obj/item/slime_extract,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledslimecore

/datum/recipe/pot/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup

/datum/recipe/pot/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/mushroomsoup

/datum/recipe/pot/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/chawanmushi

/datum/recipe/pot/beetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup

/datum/recipe/pot/boiledrice
	reagents = list("water" = 10, "rice" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledrice

/datum/recipe/pot/spagettiboiled
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pasta/spagettiboiled

/datum/recipe/pot/spagettitomato
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pasta/spagettitomato

/datum/recipe/pot/macaroniboiled
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/macaroni
	)
	result = /obj/item/reagent_containers/food/snacks/pasta/macaroniboiled
