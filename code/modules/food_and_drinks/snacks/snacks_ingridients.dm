
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
	bitesize = 2
	list_reagents = list("nutriment" = 6)

// Monkey Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/attackby(obj/item/weapon/reagent_containers/food/snacks/cheesewedge/W, mob/user)
	if(istype(W))// && !istype(src,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(W)
		qdel(src)
		return
	else
		..()

// Human Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/human/burger/attackby(obj/item/weapon/reagent_containers/food/snacks/cheesewedge/W, mob/user)
	if(istype(W))
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(W)
		qdel(src)
		return
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "flatbread"
	bitesize = 2
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)

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
	list_reagents = list("protein" = 2)


/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list("protein" = 2)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		to_chat(user, "<span class='notice'>You make a bacon.</span>")
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "rawmeatball"
	raw = TRUE
	bitesize = 2
	list_reagents = list("protein" = 2)

//////////////////
// Potato stuff	//
//////////////////

// potato + knife = raw sticks
/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(src)
		to_chat(user, "You cut the potato.")
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_and_drinks/ingredients.dmi'
	icon_state = "rawsticks"
	raw = TRUE
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
