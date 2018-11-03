
///-----------------------------------------------------//
///														//
///						Burgers							//
///														//
///-----------------------------------------------------//

//THE FATHER OF THEM ALL
/obj/item/weapon/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon = 'icons/obj/food_and_drinks/burgers.dmi'
	icon_state = "borglar"
	filling_color = "#D63C3C"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "protein" = 3, "vitamin" = 1)
	var/sauced_icon = "sauced_borglar"//= icon with ketchup on it

/obj/item/weapon/reagent_containers/food/snacks/burger/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(sauced_icon)
		if((get_reagent_amount("ketchup") > 1) || (get_reagent_amount("capsaicin") > 1))
			icon_state = sauced_icon
			desc = "[initial(desc)]<br><span class='rose'>It has [W] on it</span>"

/obj/item/weapon/reagent_containers/food/snacks/burger/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	sauced_icon = "sauced_brainburger"
	filling_color = "#F2B6EA"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/brainburger/atom_init()
	. = ..()
	reagents.add_reagent("alkysine", 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	sauced_icon = "sauced_ghostburger"
	filling_color = "#FFF2FF"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/ghostburger/atom_init()
	. = ..()
	reagents.add_reagent("ectoplasm", 2)


/obj/item/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#FFDEFE"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishburger/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("carpotoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#FFFEE0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofuburger/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	if(prob(5))
		reagents.add_reagent("nanites", 2)
		reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	volume = 100
	bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig/atom_init()
	. = ..()
	reagents.add_reagent("nanites", 100)
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43DE18"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenoburger/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/clownburger
	name = "Clown Burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#FF00FF"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/clownburger/atom_init()
	. = ..()
/*
	var/datum/disease/F = new /datum/disease/pierrot_throat(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 4, data)
*/
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#FFFFFF"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mimeburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)





///////////////////////////////////////////////////







/obj/item/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "prions" = 10, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#FFF2FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#D63C3C"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "nanomachines" = 10, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	volume = 120
	bitesize = 3
	list_reagents = list("nutriment" = 6, "nanomachines" = 70, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43DE18"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/clownburger
	name = "Clown Burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#FF00FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/baseballburger
	name = "home run baseball burger"
	desc = "It's still warm. The steam coming off of it looks like baseball."
	icon_state = "baseball"
	filling_color = "#CD853F"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#D505FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#E3D681"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#CCA26A"
	bitesize = 7
	list_reagents = list("nutriment" = 40, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#B572AB"
	bitesize = 3

/obj/item/reagent_containers/food/snacks/jellyburger/slime
	list_reagents = list("nutriment" = 6, "slimejelly" = 5, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/jellyburger/cherry
	list_reagents = list("nutriment" = 6, "cherryjelly" = 5, "vitamin" = 1)































