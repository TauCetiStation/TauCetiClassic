#define MAX_BARRELS_SAVED 3
#define MAX_TABLES_SAVED 2
#define MAX_BOXES_SAVED 1

var/global/list/preservation_barrels = list()
var/global/list/preservation_tables = list()
var/global/list/preservation_boxes = list()

ADD_TO_GLOBAL_LIST(/obj/structure/preservation_barrel, preservation_barrels)
/obj/structure/preservation_barrel
	name = "wooden barrel"
	desc = "Для заготовления жидкостей."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "preservation_barrel"

	density = TRUE
	anchored = TRUE

	var/obj/item/weapon/storage/internal/internal_storage

	var/save_id = 0

	var/list/can_also_preserve = list("items" = list(), "reagents" = list(/datum/reagent/sugar))

/obj/structure/preservation_barrel/kitchen
	save_id = "kitchen"

/obj/structure/preservation_barrel/maintenance
	save_id = "maintenance"

/obj/structure/preservation_barrel/bar
	save_id = "bar"

/obj/structure/preservation_barrel/church
	save_id = "church"

/obj/structure/preservation_barrel/examine(mob/user)
	. = ..()

	if(Adjacent(user) && reagents.reagent_list.len)
		to_chat(user, "Smells like: [reagents.get_master_reagent_name()]")

/obj/structure/preservation_barrel/atom_init()
	. = ..()
	create_reagents(200)

	internal_storage = new(src)
	internal_storage.set_slots(slots = 1, slot_size = SIZE_BIG)

/obj/structure/preservation_barrel/proc/start_processing_recipes()
	if(reagents.total_volume == reagents.maximum_volume)
		reagents.remove_any(1)
	reagents.add_reagent("agium", 1)

	addtimer(CALLBACK(src, PROC_REF(stop_processing_recipes)), 2 SECONDS)

/obj/structure/preservation_barrel/proc/stop_processing_recipes()
	reagents.del_reagent("agium")
	var/vinegar_amount = reagents.get_reagent_amount("vinegar")
	for(var/datum/reagent/consumable/ethanol/R in reagents.reagent_list)
		reagents.remove_reagent(R.id, min(5, vinegar_amount))
		reagents.add_reagent("vinegar", min(5, vinegar_amount))

/obj/structure/preservation_barrel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/C = I
		if(C.is_open_container())
			try_transfer_reagents(I, user)
			return
	if(internal_storage.can_be_inserted(I))
		internal_storage.handle_item_insertion(I)

	return ..()

/obj/structure/preservation_barrel/proc/try_transfer_reagents(obj/item/weapon/reagent_containers/I, mob/user)
	var/transfer_amount = I.amount_per_transfer_from_this

	var/list/liquids = list()
	var/static/radial_pour_in = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_increase")
	var/static/radial_pour_out = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_decrease")
	liquids["Влить"] = radial_pour_in
	liquids["Слить"] = radial_pour_out

	var/selection = show_radial_menu(user, src, liquids, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	switch(selection)
		if("Слить")
			if(I.reagents.total_volume >= I.reagents.maximum_volume)
				to_chat(user, "<span class = 'rose'>[I] is full.</span>")
				return
			if(!reagents.total_volume && reagents)
				to_chat(user, "<span class = 'rose'>[src] is empty.</span>")
				return
			reagents.trans_to(I, transfer_amount)
		if("Влить")
			if(src.reagents.total_volume >= src.reagents.maximum_volume)
				to_chat(user, "<span class = 'rose'>[src] is full.</span>")
				return
			if(!I.reagents.total_volume && I.reagents)
				to_chat(user, "<span class = 'rose'>[I] is empty.</span>")
				return
			I.reagents.trans_to(src, transfer_amount)

/obj/structure/preservation_barrel/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	internal_storage.open(user)
	..()



/obj/structure/preservation_barrel/continuity_read(list/barrel_record)
	var/list/itemslist = params2list(barrel_record["items"])
	var/list/reagentslist = params2list(barrel_record["reagents"])

	for(var/itemtype in itemslist)
		new itemtype(internal_storage)

	for(var/reagentid in reagentslist)
		reagents.add_reagent("[reagentid]", text2num(reagentslist[reagentid]))

	start_processing_recipes()
	update_icon()

/obj/structure/preservation_barrel/continuity_write()
	var/list/barrel_record = list("items" = list(), "reagents" = list())

	for(var/obj/item/F in internal_storage.contents)
		if(istype(F, /obj/item/weapon/reagent_containers/food/snacks/grown) || (F.type in can_also_preserve["items"]))
			barrel_record["items"] += F.type

	for(var/datum/reagent/R in reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable) || (R.type in can_also_preserve["reagents"]))
			barrel_record["reagents"] += list("[R.id]" = "[R.volume]")

	barrel_record["items"] = list2params(barrel_record["items"])
	barrel_record["reagents"] = list2params(barrel_record["reagents"])

	return list2params(barrel_record)



ADD_TO_GLOBAL_LIST(/obj/structure/preservation_table, preservation_tables)
/obj/structure/preservation_table
	name = "preservation table"
	desc = "Для заготовления еды."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "preservation_table"

	density = TRUE
	anchored = TRUE

	var/obj/item/weapon/storage/internal/internal_storage

	var/save_id = 0

	var/icon/foods_inside

	var/foods_offsets = list(list(-6, 10), list(6, 10), list(-6, -4), list(6, -4))

/obj/structure/preservation_table/kitchen
	save_id = "kitchen"

/obj/structure/preservation_table/atom_init()
	. = ..()

	internal_storage = new(src)
	internal_storage.set_slots(slots = 4, slot_size = SIZE_BIG, visible = TRUE)

/obj/structure/preservation_table/attackby(obj/item/I, mob/user, params)
	if(internal_storage.can_be_inserted(I))
		internal_storage.handle_item_insertion(I)

	return ..()

/obj/structure/preservation_table/proc/start_processing_recipes()
	for(var/obj/item/I in internal_storage.contents)
		for(var/RecType in subtypesof(/datum/preservation_recipe))
			var/datum/preservation_recipe/Rec = new RecType
			if(Rec.ingredient == I.type)
				qdel(I)
				new Rec.result(internal_storage)

/obj/structure/preservation_table/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	internal_storage.open(user)
	..()

/obj/structure/preservation_table/update_icon()
	cut_overlay(foods_inside)
	foods_inside = icon('icons/effects/32x32.dmi', "blank")

	var/i = 1
	for(var/obj/item/F in internal_storage.contents)
		var/list/offsets = foods_offsets[i]
		foods_inside.Blend(icon(F.icon, F.icon_state), ICON_OVERLAY, offsets[1], offsets[2])
		i++

	add_overlay(foods_inside)



/obj/structure/preservation_table/continuity_read(list/table_record)
	for(var/itemtype in table_record)
		new itemtype(internal_storage)

	start_processing_recipes()
	update_icon()

/obj/structure/preservation_table/continuity_write()
	var/list/table_record = list()

	var/i = 1
	for(var/obj/item/weapon/reagent_containers/food/snacks/F in internal_storage.contents)
		table_record["[i]"] = F.type
		i++

	return list2params(table_record)



ADD_TO_GLOBAL_LIST(/obj/structure/preservation_box, preservation_boxes)
/obj/structure/preservation_box
	name = "preservation box"
	desc = "Для заготовления овощей."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "preservation_box"

	density = TRUE
	anchored = TRUE

	var/save_id = 0

	var/obj/item/weapon/storage/internal/internal_storage

	var/icon/vegs_inside

/obj/structure/preservation_box/kitchen
	save_id = "kitchen"

/obj/structure/preservation_box/atom_init()
	. = ..()

	internal_storage = new(src)
	internal_storage.set_slots(slots = 14, slot_size = SIZE_BIG, visible = TRUE)

/obj/structure/preservation_box/attackby(obj/item/I, mob/user, params)
	if(internal_storage.can_be_inserted(I))
		internal_storage.handle_item_insertion(I)

	return ..()

/obj/structure/preservation_box/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	internal_storage.open(user)
	..()

/obj/structure/preservation_box/update_icon()
	cut_overlay(vegs_inside)
	vegs_inside = icon('icons/effects/32x32.dmi', "blank")

	for(var/obj/item/V in internal_storage.contents)
		vegs_inside.Blend(icon(V.icon, V.icon_state), ICON_OVERLAY, rand(-7, 7), rand(0, 7))

	vegs_inside.Blend(icon('icons/obj/kitchen.dmi', "preservation_box_mask"), ICON_AND)

	add_overlay(vegs_inside)



/obj/structure/preservation_box/continuity_read(list/box_record)
	for(var/itemtype in box_record)
		new itemtype(internal_storage)

	update_icon()

/obj/structure/preservation_box/continuity_write()
	var/list/box_record = list()

	var/i = 1
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/F in internal_storage.contents)
		box_record["[i]"] = F.type
		i++

	return list2params(box_record)



#undef MAX_BARRELS_SAVED
#undef MAX_TABLES_SAVED
#undef MAX_BOXES_SAVED
