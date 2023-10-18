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

	flags = OPENCONTAINER

	density = TRUE
	anchored = TRUE

	var/list/datum/recipe/available_recipes = list()

	var/save_id = 0

/obj/structure/preservation_barrel/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(200)
	reagents = R
	R.my_atom = src

	save_id = global.preservation_barrels.Find(src)
	AddComponent(/datum/component/roundstart_roundend, CALLBACK(src, PROC_REF(read_data)), CALLBACK(src, PROC_REF(write_data)), CALLBACK(src, PROC_REF(erase_data)))

/obj/structure/preservation_barrel/proc/process_recipes()
	for(var/RecType in subtypesof(/datum/barrelrecipe))
		var/datum/barrelrecipe/Rec = new RecType
		var/list/checkreagents = Rec.ingredients.Copy()

		while(check_reagents_for_recipe(checkreagents))
			for(var/ing in checkreagents)
				reagents.remove_reagent(ing, checkreagents[ing])

			for(var/thing in Rec.results)
				if(ispath(thing))
					new thing(src)
					continue
				reagents.add_reagent(thing, Rec.results[thing])

/obj/structure/preservation_barrel/proc/check_reagents_for_recipe(list/checkreagents)
	for(var/ing in checkreagents)
		if(!reagents.has_reagent(ing, checkreagents[ing]))
			return FALSE

	return TRUE

/obj/structure/preservation_barrel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers))
		try_transfer_reagents(I, user)
		return

	return ..()

/obj/structure/preservation_barrel/proc/try_transfer_reagents(obj/item/I, mob/user)
	var/transfer_amount = 5
	if(istype(I, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/G = I
		transfer_amount = G.amount_per_transfer_from_this

	var/list/liquids = list()
	var/static/radial_pour_in = image(icon = 'icons/hud/radial.dmi', icon_state = "drop")
	liquids["Влить"] = radial_pour_in
	for(var/datum/reagent/R in reagents.reagent_list)
		var/image/holder = image(icon = 'icons/hud/radial.dmi', icon_state = "colored_drop")
		holder.color = R.color
		liquids[R] = holder


	var/selection = show_radial_menu(user, src, liquids, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	if(istype(selection, /datum/reagent))
		var/datum/reagent/Reag = selection
		if(I.reagents.total_volume >= I.reagents.maximum_volume)
			to_chat(user, "<span class = 'rose'>[I] is full.</span>")
			return
		if(!reagents.total_volume && reagents)
			to_chat(user, "<span class = 'rose'>[src] is empty.</span>")
			return
		reagents.trans_id_to(I, Reag.id, 5)
	else
		if(src.reagents.total_volume >= src.reagents.maximum_volume)
			to_chat(user, "<span class = 'rose'>[src] is full.</span>")
			return
		if(!I.reagents.total_volume && I.reagents)
			to_chat(user, "<span class = 'rose'>[I] is empty.</span>")
			return
		I.reagents.trans_to(src, transfer_amount)

/obj/structure/preservation_barrel/attack_hand(mob/user)
	if(!contents.len)
		..()

	var/list/foods = list()
	for(var/obj/item/F in contents)
		foods[F] = F.appearance

	var/obj/item/selection = show_radial_menu(user, src, foods, require_near = TRUE, tooltips = TRUE)

	if(selection)
		if(ishuman(user))
			user.put_in_hands(selection)
		else
			selection.forceMove(get_turf(src))



/obj/structure/preservation_barrel/proc/read_data()
	if(!save_id || save_id > MAX_BARRELS_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresBarrel.sav")
	var/list_of_liquids

	S["liquidslist_[save_id]"] >> list_of_liquids

	if(!list_of_liquids || list_of_liquids == "Nothing")
		return

	var/list/list_of_reagents = params2list(list_of_liquids)
	for(var/reagentid in list_of_reagents)
		reagents.add_reagent("[reagentid]", text2num(list_of_reagents[reagentid]))

	process_recipes()
	update_icon()

/obj/structure/preservation_barrel/proc/write_data()
	if(!save_id || save_id > MAX_BARRELS_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresBarrel.sav")

	var/list/allliquids = list()
	for(var/datum/reagent/consumable/R in reagents.reagent_list)
		allliquids["[R.id]"] = "[R.volume]"

	S["liquidslist_[save_id]"] << list2params(allliquids)

/obj/structure/preservation_barrel/proc/erase_data()
	if(!save_id || save_id > MAX_BARRELS_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresBarrel.sav")

	S["liquidslist_[save_id]"] << "Nothing"




ADD_TO_GLOBAL_LIST(/obj/structure/preservation_table, preservation_tables)
/obj/structure/preservation_table
	name = "preservation table"
	desc = "Для заготовления еды."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "preservation_table"

	density = TRUE
	anchored = TRUE

	var/list/datum/recipe/available_recipes = list()

	var/save_id = 0

	var/icon/foods_inside

	var/foods_offsets = list(list(-6, 10), list(6, 10), list(-6, -4), list(6, -4))

/obj/structure/preservation_table/atom_init()
	. = ..()

	save_id = global.preservation_tables.Find(src)
	AddComponent(/datum/component/roundstart_roundend, CALLBACK(src, PROC_REF(read_data)), CALLBACK(src, PROC_REF(write_data)), CALLBACK(src, PROC_REF(erase_data)))

/obj/structure/preservation_table/proc/process_recipes()
	for(var/obj/item/I in contents)
		for(var/RecType in subtypesof(/datum/preservation_recipe))
			var/datum/preservation_recipe/Rec = new RecType
			if(Rec.ingredient == I.type)
				qdel(I)
				new Rec.result(src)

/obj/structure/preservation_table/attackby(obj/item/I, mob/user, params)
	if(contents.len < 4)
		user.drop_from_inventory(I, src)
		update_icon()
	else
		to_chat(user, "<span class='notice'>Стол полон.</span>")

		return ..()

/obj/structure/preservation_table/attack_hand(mob/user)
	if(!contents.len)
		..()

	var/list/foods = list()
	for(var/obj/item/F in contents)
		foods[F] = F.appearance

	var/obj/item/selection = show_radial_menu(user, src, foods, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	if(ishuman(user))
		user.put_in_hands(selection)
	else
		selection.forceMove(get_turf(src))
	update_icon()

/obj/structure/preservation_table/update_icon()
	cut_overlay(foods_inside)
	foods_inside = icon('icons/effects/32x32.dmi', "blank")

	var/i = 1
	for(var/obj/item/F in contents)
		var/list/offsets = foods_offsets[i]
		foods_inside.Blend(icon(F.icon, F.icon_state), ICON_OVERLAY, offsets[1], offsets[2])
		i++

	add_overlay(foods_inside)



/obj/structure/preservation_table/proc/read_data()
	if(!save_id || save_id > MAX_TABLES_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresTable.sav")
	var/list_of_foods

	S["foodslist_[save_id]"] >> list_of_foods

	if(!list_of_foods || list_of_foods == "Nothing")
		return

	var/list/list_of_types = params2list(list_of_foods)
	for(var/i = 1, i <= list_of_types.len, i++)
		var/food_type = text2path(list_of_types["[i]"])
		new food_type(src)

	process_recipes()
	update_icon()

/obj/structure/preservation_table/proc/write_data()
	if(!save_id || save_id > MAX_TABLES_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresTable.sav")

	var/list/allfoods = list()
	var/i = 1
	for(var/obj/item/weapon/reagent_containers/food/snacks/F in contents)
		allfoods["[i]"] = "[F.type]"
		i++

	S["foodslist_[save_id]"] << list2params(allfoods)

/obj/structure/preservation_table/proc/erase_data()
	if(!save_id || save_id > MAX_TABLES_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresTable.sav")

	S["foodslist_[save_id]"] << "Nothing"




ADD_TO_GLOBAL_LIST(/obj/structure/preservation_box, preservation_boxes)
/obj/structure/preservation_box
	name = "preservation box"
	desc = "Для заготовления овощей."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "preservation_box"

	density = TRUE
	anchored = TRUE

	var/save_id = 0

	var/max_vegetables = 10

	var/icon/vegs_inside

/obj/structure/preservation_box/atom_init()
	. = ..()

	save_id = global.preservation_boxes.Find(src)
	AddComponent(/datum/component/roundstart_roundend, CALLBACK(src, PROC_REF(read_data)), CALLBACK(src, PROC_REF(write_data)), CALLBACK(src, PROC_REF(erase_data)))

/obj/structure/preservation_box/attackby(obj/item/I, mob/user, params)
	if(contents.len < max_vegetables)
		user.drop_from_inventory(I, src)
		update_icon()
	else
		to_chat(user, "<span class='notice'>Короб полон.</span>")

		return ..()

/obj/structure/preservation_box/attack_hand(mob/user)
	if(!contents.len)
		..()

	var/list/vegs = list()
	for(var/obj/item/V in contents)
		vegs[V] = V.appearance

	var/obj/item/selection = show_radial_menu(user, src, vegs, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	if(ishuman(user))
		user.put_in_hands(selection)
	else
		selection.forceMove(get_turf(src))
	update_icon()

/obj/structure/preservation_box/update_icon()
	cut_overlay(vegs_inside)
	vegs_inside = icon('icons/effects/32x32.dmi', "blank")

	for(var/obj/item/V in contents)
		vegs_inside.Blend(icon(V.icon, V.icon_state), ICON_OVERLAY, rand(-7, 7), rand(0, 7))

	vegs_inside.Blend(icon('icons/obj/kitchen.dmi', "preservation_box_mask"), ICON_AND)

	add_overlay(vegs_inside)



/obj/structure/preservation_box/proc/read_data()
	if(!save_id || save_id > MAX_BOXES_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresBox.sav")
	var/list_of_vegetables

	S["vegslist_[save_id]"] >> list_of_vegetables

	if(!list_of_vegetables || list_of_vegetables == "Nothing")
		return

	var/list/list_of_types = params2list(list_of_vegetables)
	for(var/i = 1, i <= list_of_types.len, i++)
		var/veg_type = text2path(list_of_types["[i]"])
		new veg_type(src)

	update_icon()

/obj/structure/preservation_box/proc/write_data()
	if(!save_id || save_id > MAX_BOXES_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresBox.sav")

	var/list/allvegs = list()
	var/i = 1
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
		allvegs["[i]"] = "[G.type]"
		i++

	S["vegslist_[save_id]"] << list2params(allvegs)

/obj/structure/preservation_box/proc/erase_data()
	if(!save_id || save_id > MAX_BOXES_SAVED || save_id <= 0)
		return

	var/savefile/S = new /savefile("data/obj_saves/PresBox.sav")

	S["vegslist_[save_id]"] << "Nothing"



#undef MAX_BARRELS_SAVED
#undef MAX_TABLES_SAVED
#undef MAX_BOXES_SAVED
