///-----------------------------------------------------//
///														//
///						Meat							//
///			Animal flesh that is eaten as food.			//
///			Contains protein.							//
///														//
///-----------------------------------------------------//

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	health = 180
	filling_color = "#FF1C1C"
	bitesize = 3
	raw = TRUE
	list_reagents = list("protein" = 6)

/obj/item/weapon/reagent_containers/food/snacks/meat/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		to_chat(user, "You cut the meat into thin strips.")
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "meat"

/obj/item/weapon/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	desc = "A slab of station reclaimed and chemically processed meat product."

/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	// same as plain meat

/obj/item/weapon/reagent_containers/food/snacks/meat/ham
	name = "Ham"
	desc = "Taste like bacon."

/obj/item/weapon/reagent_containers/food/snacks/meat/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/meat/meatwheat/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("vitamin", 2)
	reagents.add_reagent("blood", 5)

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "carpotoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	bitesize = 6
	list_reagents = list("plantmatter" = 4)

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#DB0000"
	bitesize = 3
	list_reagents = list("protein" = 12, "hyperzine" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	bitesize = 3
	list_reagents = list("protein" = 4, "toxin" = 2, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list("protein" = 4, "toxin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#DB0000"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	bitesize = 3
	list_reagents = list("protein" = 4, "carpotoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/kabob/human
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	bitesize = 2
	list_reagents = list("protein" = 8)

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	bitesize = 2
	list_reagents = list("protein" = 8)

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	bitesize = 2
	list_reagents = list("plantmatter" = 8)

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cubancarp/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("carpotoxin", 3)
	reagents.add_reagent("capsaicin", 3)