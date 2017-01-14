/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	var/max_n_of_items = 1500
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/icon_panel = "smartfridge-panel"
	var/list/item_quants = list()
	var/ispowered = 1 //starts powered
	var/isbroken = 0
	var/seconds_electrified = 0;
	var/shoot_inventory = 0
	var/locked = 0
	var/wires = 7
	var/const/WIRE_SHOCK = 1
	var/const/WIRE_SHOOTINV = 2
	var/const/WIRE_SCANID = 3 //Only used by the secure smartfridge, but required by the cut, mend and pulse procs.

/obj/machinery/smartfridge/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smartfridge(null, type)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/smartfridge/construction()
	for(var/datum/A in contents)
		qdel(A)

/obj/machinery/smartfridge/deconstruction()
	for(var/atom/movable/A in contents)
		A.loc = loc

/obj/machinery/smartfridge/RefreshParts()
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 1500 * B.rating

/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/) || istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	icon_on = "seeds"
	icon_off = "seeds-off"

/obj/machinery/smartfridge/seeds/accept_check(obj/item/O)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/storage/pill_bottle))
		if(O.contents.len)
			for(var/obj/item/I in O)
				if(!accept_check(I))
					return 0
			return 1
		return 0
	if(!istype(O,/obj/item/weapon/reagent_containers))
		return 0
	if(istype(O,/obj/item/weapon/reagent_containers/pill)) // empty pill prank ok
		return 1
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return 0
	if(istype(O,/obj/item/weapon/reagent_containers/syringe) || istype(O,/obj/item/weapon/reagent_containers/glass/bottle) || istype(O,/obj/item/weapon/reagent_containers/glass/beaker) || istype(O,/obj/item/weapon/reagent_containers/spray))
		return 1
	return 0

/obj/machinery/smartfridge/secure/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts."
	req_access_txt = "47"

/obj/machinery/smartfridge/secure/extract/accept_check(obj/item/O)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	icon_on = "smartfridge_chem"
	req_one_access_txt = "5;33"

/obj/machinery/smartfridge/secure/medbay/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/))
		return 1
	if(istype(O,/obj/item/weapon/storage/pill_bottle/))
		return 1
	if(istype(O,/obj/item/weapon/reagent_containers/pill/))
		return 1
	return 0

/obj/machinery/smartfridge/secure/virology
	name = "\improper Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	req_access_txt = "39"
	icon_state = "smartfridge_virology"
	icon_on = "smartfridge_virology"
	icon_off = "smartfridge_virology-off"

/obj/machinery/smartfridge/secure/virology/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/beaker/vial/))
		return 1
	if(istype(O,/obj/item/weapon/virusdish/))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/storage/pill_bottle) || istype(O,/obj/item/weapon/reagent_containers))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."


/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks) || istype(O,/obj/item/weapon/reagent_containers/food/condiment))
		return 1

/obj/machinery/smartfridge/process()
	if(!src.ispowered)
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/machinery/smartfridge/power_change()
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		if(!isbroken)
			icon_state = icon_on
	else
		spawn(rand(0, 15))
		src.ispowered = 0
		stat |= NOPOWER
		if(!isbroken)
			icon_state = icon_off

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, "smartfridge_open", "smartfridge", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	default_deconstruction_crowbar(O)

	if(istype(O, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
		overlays.Cut()
		if(panel_open)
			overlays += image(icon, icon_panel)
		nanomanager.update_uis(src)
		return

	if(istype(O, /obj/item/device/multitool)||istype(O, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return

	if(!src.ispowered)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(accept_check(O))
		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return 1
		else
			user.remove_from_mob(O)
			O.loc = src
			if(item_quants[O.name])
				item_quants[O.name]++
			else
				item_quants[O.name] = 1
			user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
								 "<span class='notice'>You add \the [O] to \the [src].")

			nanomanager.update_uis(src)

	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/storage/bag/plants/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(accept_check(G))
				if(contents.len >= max_n_of_items)
					to_chat(user, "<span class='notice'>\The [src] is full.</span>")
					return 1
				else
					P.remove_from_storage(G,src)
					if(item_quants[G.name])
						item_quants[G.name]++
					else
						item_quants[G.name] = 1
					plants_loaded++
		if(plants_loaded)

			user.visible_message( \
				"<span class='notice'>[user] loads \the [src] with \the [P].</span>", \
				"<span class='notice'>You load \the [src] with \the [P].</span>")
			if(P.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

		nanomanager.update_uis(src)

	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return 1

/obj/machinery/smartfridge/secure/attackby(obj/item/O, mob/user)
	if (istype(O, /obj/item/weapon/card/emag))
		emagged = 1
		locked = -1
		to_chat(user, "You short out the product lock on [src].")
		return

	..()

/obj/machinery/smartfridge/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/smartfridge/attack_ai(mob/user)
	return 0

/obj/machinery/smartfridge/attack_hand(mob/user)
	if(!ispowered) return
	if(seconds_electrified != 0)
		if(shock(user, 100))
			return

	ui_interact(user)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	user.set_machine(src)

	var/is_secure = istype(src,/obj/machinery/smartfridge/secure)

	var/data[0]
	data["contents"] = null
	data["wires"] = null
	data["panel_open"] = panel_open
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure

	var/list/items[0]
	for (var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if (count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if (items.len > 0)
		data["contents"] = items

	var/list/vendwires = null
	if (is_secure)
		vendwires = list(
			"Violet" = 1,
			"Orange" = 2,
			"Green" = 3)
	else
		vendwires = list(
			"Blue" = 1,
			"Red" = 2,
			"Black" = 3)

	var/list/vendor_wires[0]
	for (var/wire in vendwires)
		var is_uncut = wires & APCWireColorToFlag[vendwires[wire]]
		vendor_wires.Add(list(list("wire" = wire, "cut" = !is_uncut, "index" = vendwires[wire])))

	if (vendor_wires.len > 0)
		data["wires"] = vendor_wires

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/smartfridge/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	if (href_list["close"])
		user.unset_machine()
		ui.close()
		return FALSE

	if (href_list["vend"])
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/K = item_quants[index]
		var/count = item_quants[K]

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			item_quants[K] = max(count - amount, 0)

			var/i = amount
			for(var/obj/O in contents)
				if (O.name == K)
					O.loc = loc
					i--
					if (i <= 0)
						return TRUE

		return TRUE

	if (panel_open)
		if (href_list["cutwire"])
			if (!( istype(usr.get_active_hand(), /obj/item/weapon/wirecutters) ))
				to_chat(user, "You need wirecutters!")
				return FALSE

			var/wire_index = text2num(href_list["cutwire"])
			if (isWireColorCut(wire_index))
				mend(wire_index)
			else
				cut(wire_index)
			return TRUE

		if (href_list["pulsewire"])
			if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
				to_chat(usr, "You need a multitool!")
				return FALSE

			var/wire_index = text2num(href_list["pulsewire"])
			if (isWireColorCut(wire_index))
				to_chat(usr, "You can't pulse a cut wire.")
				return FALSE

			pulse(wire_index)
			return TRUE

/*************
*	Hacking
**************/

/obj/machinery/smartfridge/proc/cut(wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1
		if(WIRE_SCANID)
			src.locked = 1

/obj/machinery/smartfridge/proc/mend(wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires |= wireFlag
	switch(wireIndex)
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0
		if(WIRE_SCANID)
			src.locked = 0

/obj/machinery/smartfridge/proc/pulse(wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(WIRE_SHOCK)
			src.seconds_electrified = 30
		if(WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory
		if(WIRE_SCANID)
			src.locked = -1

/obj/machinery/smartfridge/proc/isWireColorCut(wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/smartfridge/proc/isWireCut(wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for (var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue

		item_quants[O]--
		for(var/obj/T in contents)
			if(T.name == O)
				T.loc = src.loc
				throw_item = T
				break
		break
	if(!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target,16,3,src)
	src.visible_message("\red <b>[src] launches [throw_item.name] at [target.name]!</b>")
	return 1

/obj/machinery/smartfridge/proc/shock(mob/user, prb)
	if(!ispowered) return 0
	if(!prob(prb)) return 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	return electrocute_mob(user, get_area(src), src, 0.7)

/************************
*   Secure SmartFridges
*************************/

/obj/machinery/smartfridge/secure/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if (!allowed(usr) && !emagged && locked != -1 && href_list["vend"])
		to_chat(usr, "\red Access denied.")
		return FALSE
