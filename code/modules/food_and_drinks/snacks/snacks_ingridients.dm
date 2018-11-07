
///-----------------------------------------------------//
///														//
///						Ingridients						//
///					Food that we dont eat,				//
///			 but make eatable stuff out of it			//
///														//
///-----------------------------------------------------//

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon_state = "deepfried_holder_icon"
	filling_color = "#FFAD33"
	bitesize = 2
	list_reagents = list("nutriment" = 3)

//////////////////
// Dough stuff	//
//////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	raw = TRUE
	list_reagents = list("nutriment" = 6)

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	raw = TRUE
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	raw = TRUE
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "bun"
	filling_color = "#EDDD00"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "flatbread"
	filling_color = "#EDDD00"
	bitesize = 2
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spagetti
	name = "spaghetti"
	desc = "A bundle of raw spaghetti."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "spagetti"
	filling_color = "#EDDD00"
	bitesize = 1
	list_reagents = list("nutriment" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/macaroni
	name = "macaroni twists"
	desc = "These are little twists of raw macaroni."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "macaroni"
	filling_color = "#EDDD00"
	bitesize = 1
	list_reagents = list("nutriment" = 1, "vitamin" = 1)

//////////////////
// Meat stuff	//
//////////////////

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	raw = TRUE
	list_reagents = list("protein" = 3)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/attack_self(mob/user)
	if(src != /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human)
		var/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/F = new/obj/item/weapon/reagent_containers/food/snacks/rawmeatball(src)
	else
		var/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/human/F = new/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/human(src)
	if(user.l_hand == src || user.r_hand == src)
				user.put_in_hands(F)
	to_chat(user, "<span class='notice'>You roll [src] into a [F.name]</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human
	desc = "A thin piece of... Something is wrong with that cutlet."

/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon_state = "cutlet"
	filling_color = "#DB0000"
	bitesize = 2
	list_reagents = list("protein" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cutlet/human
	desc = "A tasty meat... Something is wrong with that cutlet."

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "rawmeatball"
	raw = TRUE
	bitesize = 2
	list_reagents = list("protein" = 3)

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/attack_self(mob/user)
	if(src != /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human)
		var/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/F = new/obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
	else
		var/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human/F = new/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human(src)
	if(user.l_hand == src || user.r_hand == src)
				user.put_in_hands(F)
	to_chat(user, "<span class='notice'>You roll [src] into a [F.name]</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/human
	desc = "A raw meatball... Something is wrong with that thing."

/obj/item/weapon/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#DB0000"
	bitesize = 2
	list_reagents = list("protein" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/meatball/human
	desc = "A great meal all round... Something is wrong with that thing."

/obj/item/weapon/reagent_containers/food/snacks/raw_bacon
	name = "raw bacon"
	desc = "It's fleshy and pink!"
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "raw_bacon"
	bitesize = 3
	raw = TRUE
	list_reagents = list("protein" = 1)

//////////////////
// Potato stuff	//
//////////////////

/obj/item/weapon/reagent_containers/food/snacks/cleanedpotato
	name = "cleaned potato"
	desc = "Raw potato. Guilty cadet's best friend."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "cleanedpotato"
	bitesize = 2
	list_reagents = list("plantmatter" = 3)

/obj/item/weapon/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "rawsticks"
	bitesize = 2
	list_reagents = list("plantmatter" = 3)

//////////////////
// Ectoplasm o.O//
//////////////////

/obj/item/weapon/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	desc = "Spooky! Do not consume under any circumstances."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	list_reagents = list("ectoplasm" = 5)
