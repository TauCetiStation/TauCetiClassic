
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
	if(sauced_icon && icon_state == initial(icon_state))
		if((get_reagent_amount("ketchup") > 1) || (get_reagent_amount("capsaicin") > 1))
			icon_state = sauced_icon
			desc = "[desc]<br><span class='rose'>It has [W] on it</span>"

///////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/burger/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	sauced_icon = "sauced_brainburger"
	filling_color = "#F2B6EA"

/obj/item/weapon/reagent_containers/food/snacks/burger/brainburger/atom_init()
	. = ..()
	reagents.add_reagent("alkysine", 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	sauced_icon = "sauced_ghostburger"
	filling_color = "#FFF2FF"

/obj/item/weapon/reagent_containers/food/snacks/burger/ghostburger/atom_init()
	. = ..()
	reagents.add_reagent("ectoplasm", 2)

/obj/item/weapon/reagent_containers/food/snacks/burger/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/weapon/reagent_containers/food/snacks/burger/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "borglar"
	sauced_icon = "sauced_borglar"

/obj/item/weapon/reagent_containers/food/snacks/burger/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	sauced_icon = "sauced_cheeseburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/cheeseburger/atom_init()
	. = ..()
	reagents.add_reagent("cheese", 3)//Reminder - some time there was no cheese reagent in cheeseburger...

/obj/item/weapon/reagent_containers/food/snacks/burger/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	sauced_icon = "sauced_fishburger"
	filling_color = "#FFDEFE"

/obj/item/weapon/reagent_containers/food/snacks/burger/fishburger/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("carpotoxin", 2)

/obj/item/weapon/reagent_containers/food/snacks/burger/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	sauced_icon = "sauced_tofuburger"
	filling_color = "#FFFEE0"

/obj/item/weapon/reagent_containers/food/snacks/burger/tofuburger/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 4)

/obj/item/weapon/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	sauced_icon = "sauced_roburger"
	filling_color = "#CCCCCC"

/obj/item/weapon/reagent_containers/food/snacks/burger/roburger/atom_init()
	. = ..()
	if(prob(60))
		reagents.add_reagent("nanites", 2)

/obj/item/weapon/reagent_containers/food/snacks/burger/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	sauced_icon = "sauced_roburger"
	filling_color = "#CCCCCC"
	volume = 100
	bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/burger/roburgerbig/atom_init()
	. = ..()
	reagents.add_reagent("nanites", 50)

/obj/item/weapon/reagent_containers/food/snacks/burger/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	sauced_icon = "sauced_xburger"
	filling_color = "#43DE18"

/obj/item/weapon/reagent_containers/food/snacks/burger/xenoburger/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/clownburger
	name = "Clown Burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	sauced_icon = "sauced_clownburger"
	filling_color = "#FF00FF"

/obj/item/weapon/reagent_containers/food/snacks/burger/clownburger/atom_init()
	. = ..()
/*
	var/datum/disease/F = new /datum/disease/pierrot_throat(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 4, data)
*/
	reagents.add_reagent("lube", 4)

/obj/item/weapon/reagent_containers/food/snacks/burger/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	sauced_icon = "sauced_mimeburger"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/burger/mimeburger/atom_init()
	. = ..()
	reagents.add_reagent("nothing", 4)

/obj/item/weapon/reagent_containers/food/snacks/burger/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	sauced_icon = "sauced_spellburger"
	filling_color = "#D505FF"

/obj/item/weapon/reagent_containers/food/snacks/burger/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	sauced_icon = "sauced_bigbiteburger"
	filling_color = "#E3D681"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/burger/bigbiteburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/burger/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	sauced_icon = "sauced_superbiteburger"
	filling_color = "#CCA26A"
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/burger/superbiteburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 50)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/burger/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#B572AB"

/obj/item/weapon/reagent_containers/food/snacks/burger/jellyburger/slime

/obj/item/weapon/reagent_containers/food/snacks/burger/jellyburger/slime/atom_init()
	. = ..()
	reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/burger/jellyburger/cherry

/obj/item/weapon/reagent_containers/food/snacks/burger/jellyburger/cherry/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 5)
