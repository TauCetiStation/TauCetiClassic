/obj/machinery/labor_counter_machine
	name = "labor counting machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = TRUE
	anchored = TRUE
	//speed_process = TRUE
	var/obj/machinery/labor_counter_console/console
	var/list/acceptable_products = list(/obj/item/stack, /obj/item/weapon/reagent_containers/food/snacks/grown)

/obj/machinery/labor_counter_machine/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/labor_counter_machine/process()
	var/turf/input_turf = get_step(src, dir)
	var/turf/output_turf = get_step(src, turn(dir, 180))
	var/i = 0

	for (var/obj/item/I in input_turf.contents)
		if(is_type_in_list(I, acceptable_products))
			count_product(I)
			I.Move(output_turf)
			i++
			if (i >= 10)
				return

/obj/machinery/labor_counter_machine/proc/count_product(obj/item/product)
	var/amount = 1
	var/datum/labor/rate

	var/datum/labor/L
	for(var/tag in global.labor_rates)
		L = global.labor_rates[tag]
		if(istype(product, L.product))
			rate = L
			break
	if(!rate)
		return

	if(istype(product, /obj/item/stack))
		var/obj/item/stack/S = product
		amount = S.amount

	console.add_product(rate.nametag, amount)

/**********************Labor products counter console**************************/
/obj/machinery/labor_counter_console
	name = "payout console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/item/weapon/card/id/labor/inserted_id
	var/obj/machinery/labor_counter_machine/machine
	var/credits = 0
	var/list/product_income = list()

/obj/machinery/labor_counter_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/labor_counter_console/atom_init_late()
	machine = locate(/obj/machinery/labor_counter_machine) in range(5, src)
	if (machine)
		machine.console = src
	else
		log_debug("Payout console at [x], [y], [z] could not find its machine!")
		qdel(src)

/obj/machinery/labor_counter_console/proc/add_product(nametag, amount)
	var/datum/labor/L = global.labor_rates[nametag]
	if(!L || amount <= 0)
		return

	var/CR = product_income[nametag] ? product_income[nametag] : 0
	CR += L.price * amount
	credits += L.price * amount + round(L.high_priority ? L.price * 0.5 * amount : 0) //If high priority is set, giving extra 50%
	product_income[nametag] = CR
	SStgui.update_uis(src)

/obj/machinery/labor_counter_console/attack_hand(mob/user)
	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/labor_counter_console/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/id/labor))
		if(!powered())
			return
		if(!inserted_id && user.unEquip(I))
			I.forceMove(src)
			inserted_id = I
			SStgui.update_uis(src)
		return
	..()

/obj/machinery/labor_counter_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaborPayout", name)
		ui.open()

/obj/machinery/labor_counter_console/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()
	data["unclaimedPayout"] = credits

	if(inserted_id)
		data["has_id"] = TRUE
		data["id"] = list(
			"name" = inserted_id.registered_name,
			"credits" = inserted_id.labor_credits,
		)
	else
		data["has_id"] = FALSE

	var/list/income = list()
	for(var/tag in global.labor_rates)
		if(!product_income[tag])
			continue
		income.Add(list(
			"nametag" = tag,
			"credits" = product_income[tag]
		))
	data["income"] = income

	return data

/obj/machinery/labor_counter_console/tgui_act(action, list/params)
	if(..())
		return TRUE

	add_fingerprint(usr)
	switch(action)
		if("logoff")
			if(!inserted_id)
				return
			usr.put_in_hands(inserted_id)
			inserted_id = null
			. = TRUE
		if("claim")
			if(istype(inserted_id))
				inserted_id.labor_credits += credits
				credits = 0
				product_income.Cut()
			. = TRUE
		if("insert")
			var/obj/item/weapon/card/id/labor/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_from_inventory(I, src)
				inserted_id = I
			else
				to_chat(usr, "<span class='warning'>No valid ID.</span>")
			. = TRUE
