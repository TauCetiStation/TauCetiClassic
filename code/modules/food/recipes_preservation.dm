//Preservation Barrel
/datum/barrelrecipe
	var/list/ingredients
	var/list/results

/datum/barrelrecipe/moonshine
	ingredients = list("nutriment" = 10, "enzyme" = 1)
	results = list("moonshine" = 10)

/datum/barrelrecipe/grenadine
	ingredients = list("berryjuice" = 10, "enzyme" = 1)
	results = list("grenadine" = 10)

/datum/barrelrecipe/wine
	ingredients = list("grapejuice" = 10, "enzyme" = 1)
	results = list("wine" = 10)

/datum/barrelrecipe/pwine
	ingredients = list("poisonberryjuice" = 10, "enzyme" = 1)
	results = list("pwine" = 10)

/datum/barrelrecipe/melonliquor
	ingredients = list("watermelonjuice" = 10, "enzyme" = 1)
	results = list("melonliquor" = 10)

/datum/barrelrecipe/bluecuracao
	ingredients = list("orangejuice" = 10, "enzyme" = 1)
	results = list("bluecuracao" = 10)

/datum/barrelrecipe/beer
	ingredients = list("cornoil" = 10, "enzyme" = 1)
	results = list("beer" = 10)

/datum/barrelrecipe/gourdbeer
	ingredients = list("gourd" = 10, "enzyme" = 1)
	results = list("gourdbeer" = 10)

/datum/barrelrecipe/vodka
	ingredients = list("potato" = 10, "enzyme" = 1)
	results = list("vodka" = 10)

/datum/barrelrecipe/sake
	ingredients = list("rice" = 10, "enzyme" = 1)
	results = list("sake" = 10)

/datum/barrelrecipe/kahlua
	ingredients = list("coffee" = 5, "sugar" = 5, "enzyme" = 1)
	results = list("kahlua" = 10)

/datum/barrelrecipe/mead
	ingredients = list("sugar" = 5, "water" = 5, "enzyme" = 1)
	results = list("mead" = 10)

/datum/barrelrecipe/cheese
	ingredients = list("milk" = 40, "enzyme" = 1)
	results = list(/obj/item/weapon/reagent_containers/food/snacks/unfinished_cheese = 1)



//Preservation Table
/datum/preservation_recipe
	var/ingredient
	var/result

/datum/preservation_recipe/cheese
	ingredient = /obj/item/weapon/reagent_containers/food/snacks/unfinished_cheese
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
