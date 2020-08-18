/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Book bag
 *		Trash Bag
 *		Bluespace trash bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Cash Bag
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/weapon/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 0 // UNStABLE AS FuCK, turn on when it stops crashing clients
	use_to_pickup = 1
	slot_flags = SLOT_FLAGS_BELT

// -----------------------------
//           Book bag
// -----------------------------
/obj/item/weapon/storage/bag/bookbag
	name = "book bag"
	desc = "A bag for knowledge."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	item_state = "bookbag"
	display_contents_with_number = 0 //This would look really stupid otherwise
	storage_slots = 7
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	w_class = ITEM_SIZE_LARGE //Bigger than a book because physics
	can_hold = list(/obj/item/weapon/book, /obj/item/weapon/storage/bible, /obj/item/weapon/spellbook)

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/weapon/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	item_state = "trashbag"

	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	can_hold = list() // any
	cant_hold = list("/obj/item/weapon/disk/nuclear")

/obj/item/weapon/storage/bag/trash/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	. = ..()
	if(.)
		update_w_class()

/obj/item/weapon/storage/bag/trash/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	. = ..()
	if(.)
		update_w_class()

/obj/item/weapon/storage/bag/trash/can_be_inserted(obj/item/W, mob/user, stop_messages = FALSE)
	if(istype(loc, /obj/item/weapon/storage))
		if(!stop_messages)
			to_chat(user, "<span class='notice'>Take [src] out of [loc] first.</span>")
		return FALSE //causes problems if the bag expands and becomes larger than loc can hold, so disallow it
	return ..()

/obj/item/weapon/storage/bag/trash/proc/update_w_class()
	w_class = initial(w_class)
	for(var/obj/item/I in contents)
		w_class = max(w_class, I.w_class)

	var/cur_storage_space = storage_space_used()
	while(base_storage_capacity(w_class) < cur_storage_space)
		w_class++

	w_class = min(ITEM_SIZE_HUGE, w_class)

	update_icon()

/obj/item/weapon/storage/bag/trash/get_storage_cost()
	var/used_ratio = storage_space_used()/max_storage_space
	return max(base_storage_cost(w_class), round(used_ratio*base_storage_cost(max_w_class), 1))

/obj/item/weapon/storage/bag/trash/update_icon()
	switch(w_class)
		if(2)
			icon_state = "[initial(icon_state)]"
		if(3)
			icon_state = "[initial(icon_state)]1"
		if(4)
			icon_state = "[initial(icon_state)]2"
		if(5 to INFINITY)
			icon_state = "[initial(icon_state)]3"

/obj/item/weapon/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	max_storage_space = 56


// -----------------------------
//        Plastic Bag
// -----------------------------

/obj/item/weapon/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"

	w_class = ITEM_SIZE_LARGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BOX_STORAGE
	can_hold = list() // any
	cant_hold = list("/obj/item/weapon/disk/nuclear")

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/weapon/storage/bag/ore
	name = "Mining Satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_POCKET
	w_class = ITEM_SIZE_NORMAL
	max_storage_space = 100
	can_hold = list(/obj/item/weapon/ore, /obj/item/bluespace_crystal)

/obj/item/weapon/storage/bag/ore/holding
	name = "Mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for huge amounts of ore storage. It's been outfitted with anti-malfunction safety measures."
	max_storage_space = 300
	origin_tech = "bluespace=4;materials=3;engineering=3"
	icon_state = "satchel_bspace"

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/weapon/storage/bag/plants
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	max_storage_space = 100
	max_w_class = ITEM_SIZE_NORMAL
	w_class = ITEM_SIZE_SMALL
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/grown,/obj/item/seeds,/obj/item/weapon/grown)

// -----------------------------
//          Bio bag
// -----------------------------

/obj/item/weapon/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other biological materials."
	max_storage_space = 100
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(/obj/item/slime_extract,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/blood,/obj/item/weapon/reagent_containers/food/snacks/monkeycube,/obj/item/organ)


// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/weapon/storage/bag/sheetsnatcher
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	name = "Sheet Snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."

	var/capacity = 300; //the number of sheets it can carry.
	w_class = ITEM_SIZE_NORMAL
	storage_slots = 7

	allow_quick_empty = 1 // this function is superceded

/obj/item/weapon/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!istype(W,/obj/item/stack/sheet) || istype(W,/obj/item/stack/sheet/mineral/sandstone) || istype(W,/obj/item/stack/sheet/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/S in contents)
		current += S.get_amount()
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>The snatcher is full.</span>")
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/weapon/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/sheet/S2 in contents)
		current += S2.get_amount()
	if(capacity < current + S.get_amount())//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.get_amount()

	for(var/obj/item/stack/sheet/sheet in contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = 1
			break

	if(!inserted || !S.get_amount())
		usr.remove_from_mob(S)
		usr.update_icons()	//update our overlays
		if(!S.get_amount())
			qdel(S)
		else
			S.loc = src

	if(!NoUpdate)
		update_ui_after_item_insertion()
	update_icon()
	return 1

// Modified quick_empty verb drops appropriate sized stacks
/obj/item/weapon/storage/bag/sheetsnatcher/quick_empty()
	var/location = get_turf(src)
	for(var/obj/item/stack/sheet/S in contents)
		while(S.get_amount())
			var/obj/item/stack/sheet/N = new S.type(location)
			var/stacksize = min(S.get_amount(),N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.get_amount())
			qdel(S) // todo: there's probably something missing here
	update_ui_after_item_removal()
	update_icon()

// Instead of removing
/obj/item/weapon/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	var/obj/item/stack/sheet/S = W
	if(!istype(S))
		return 0

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.get_amount() > S.max_amount)
		var/obj/item/stack/sheet/temp = new S.type(src)
		temp.amount = S.get_amount() - S.max_amount
		S.amount = S.max_amount

	return ..(S, new_location, NoUpdate)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/weapon/storage/bag/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/weapon/storage/bag/cash
	icon = 'icons/obj/storage.dmi'
	icon_state = "cashbag"
	name = "Cash bag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	max_storage_space = 100
	max_w_class = ITEM_SIZE_HUGE
	w_class = ITEM_SIZE_SMALL
	can_hold = list(/obj/item/weapon/coin,/obj/item/weapon/spacecash)
