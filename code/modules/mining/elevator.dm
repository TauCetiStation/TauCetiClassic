/obj/structure/elevator
	name = "elevator"
	cases = list("элеватор", "элеватора", "элеватору", "элеватор", "элеватором", "элеваторе")
	desc = "Большое хранилище для чего-то маленького и сыпучего."

	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator"

	density = FALSE
	anchored = TRUE

	max_integrity = 500
	resistance_flags = CAN_BE_HIT

	layer = TALL_STRUCTURE

	var/contents_type
	var/contents_amount = 0
	var/contents_max_amount = 500
	var/mutable_appearance/contents_image

	var/save_id

/obj/structure/elevator/cargo
	save_id = "cargo"

/obj/structure/elevator/atom_init()
	. = ..()

	AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(Write_Memory)), CALLBACK(src, PROC_REF(Read_Memory)), "/objects/elevators/[SSmapping.config.map_name]/[save_id]", list(
			"contents_type" = new /datum/continuity_field/type(
				in_list = global.elevator_saveables_list + null,
			),
			"contents_amount" = new /datum/continuity_field/int(
				min_num = 0,
				max_num = contents_max_amount
			),
		))

/obj/structure/elevator/Destroy()
	unload_ore(contents_amount)
	..()

/obj/structure/elevator/proc/Write_Memory()
	return list("contents_type" = contents_type, "contents_amount" = contents_amount)

/obj/structure/elevator/proc/Read_Memory(list/save_data)
	contents_type = save_data["contents_type"]
	contents_amount = save_data["contents_amount"]

	update_icon()

/obj/structure/elevator/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] заполнен на [round((contents_amount / contents_max_amount) * 100)]%</span>")

/obj/structure/elevator/update_icon()
	cut_overlay(contents_image)

	if(contents_type)
		var/obj/item/I = contents_type
		contents_image = mutable_appearance(I::icon, I::item_state_world ? I::item_state_world : I::icon_state)
		contents_image.pixel_y = 18

		add_overlay(contents_image)

/obj/structure/elevator/attack_hand(mob/user)
	var/list/choices = list()
	choices["Загрузить"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_increase")
	choices["Выгрузить (x25)"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_decrease")
	choices["Выгрузить (x50)"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_decrease")

	var/obj/item/selection = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	switch(selection)
		if("Загрузить")
			if(contents_amount >= contents_max_amount)
				to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] полон</span>")
				return

			load_ore()

		if("Выгрузить (x25)")
			if(contents_amount <= 0)
				to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] пуст</span>")
			unload_ore(25)

		if("Выгрузить (x50)")
			if(contents_amount <= 0)
				to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] пуст</span>")
			unload_ore(50)

	update_icon()

/obj/structure/elevator/proc/load_ore()
	if(!contents_type)
		var/list/possible_types = list()
		for(var/obj/item/I in loc.contents)
			if(I.type in global.elevator_saveables_list)
				possible_types += I.type

		if(!possible_types.len)
			return

		contents_type = pick(possible_types)
		load_ore()
		return

	for(var/obj/item/I in loc.contents)
		if(istype(I, contents_type))
			qdel(I)
			contents_amount++
			if(contents_amount >= contents_max_amount)
				break

	update_icon()

/obj/structure/elevator/proc/unload_ore(amount)
	if(!contents_type)
		return

	for(var/i in 1 to min(contents_amount, amount))
		new contents_type(loc)
		contents_amount--

	if(!contents_amount)
		contents_type = null

	update_icon()
