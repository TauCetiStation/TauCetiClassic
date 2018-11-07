
///-----------------------------------------------------//
///														//
///						Pasta							//
///					Italian cuisine.					//
///														//
///-----------------------------------------------------//

//Pasta as a snack type
/obj/item/weapon/reagent_containers/food/snacks/pasta
	name = "Just a template."
	icon = 'icons/obj/food_and_drinks/pasta.dmi'
	bitesize = 4
	filling_color = "#FCEE81"

/obj/item/weapon/reagent_containers/food/snacks/pasta/atom_init()
	. = ..()
	sauced_icon = "sauced_[initial(icon_state)]"//cause every pasta has it :)

//SPAGETTI
/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettiboiled
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "plantmatter" = 2, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettitomato
	name = "tomato spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "spagettitomato"
	list_reagents = list("nutriment" = 3, "plantmatter" = 3, "tomatojuice" = 6, "vitamin" = 4)
	filling_color = "#DE4545"

/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettionemeatball
	name = "spaghetti & meatball"
	desc = "Now thats a nice meatball! But its so lonely..."
	icon_state = "spagettimeatballone"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "plantmatter" = 2, "protein" = 3, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/pasta/spagetticouplemeatballs
	name = "spaghetti & meatballs"
	desc = "Happy meatball family."
	icon_state = "spagettimeatballcouple"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "plantmatter" = 2, "protein" = 6, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettispesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	list_reagents = list("nutriment" = 5, "plantmatter" = 2, "protein" = 9, "vitamin" = 5)

//MACARONI
/obj/item/reagent_containers/food/snacks/pasta/macaroniboiled
	name = "boiled macaroni"
	desc = "Just a simple boring boiled noodles. But maybe adding a cutlet will change everything."
	icon_state = "macaroniboiled"
	list_reagents = list("nutriment" = 2, "plantmatter" = 2, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/pasta/macaronionecutlet
	name = "macaroni with cutlet"
	desc = "Just like your grandma did... True worker's meal!"
	icon_state = "macaronicutletone"
	list_reagents = list("nutriment" = 3, "plantmatter" = 2, "protein" = 3, "vitamin" = 3)

/obj/item/reagent_containers/food/snacks/pasta/macaronicouplecutlets
	name = "Ultimate Worker's Meal"
	desc = "Just like your grandma did... But even better!"
	icon_state = "macaronicutletscouple"
	list_reagents = list("nutriment" = 5, "plantmatter" = 2, "protein" = 7, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/pasta/macaronicheese
	name = "macaroni cheese"
	desc = "One of the most comforting foods in the world. Apparently."
	icon_state = "macncheese"
	list_reagents = list("nutriment" = 5, "vitamin" = 2, "cheese" = 4)
