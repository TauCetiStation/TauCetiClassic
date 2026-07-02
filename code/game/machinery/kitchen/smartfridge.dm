/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	allowed_checks = ALLOWED_CHECK_NONE
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
	var/content_overlay = "smartfridge-food"
	var/datum/wires/smartfridge/wires = null

/obj/machinery/smartfridge/atom_init()
	. = ..()
	wires = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smartfridge(null, type)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()
	create_fridge_states()

/obj/machinery/smartfridge/update_icon()
	create_fridge_states()

/obj/machinery/smartfridge/proc/create_fridge_states()
	cut_overlays()
	if(stat & BROKEN)
		icon_state = "smartfridge-broken"
		add_overlay(image(icon, "smartfridge-glass-broken"))
		return
	add_overlay(image(icon, content_overlay))
	add_overlay(image(icon, "smartfridge-glass"))

/obj/machinery/smartfridge/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/smartfridge/construction()
	for(var/datum/A in contents)
		qdel(A)

/obj/machinery/smartfridge/deconstruction()
	for(var/atom/movable/A in contents)
		A.loc = loc

/obj/machinery/smartfridge/RefreshParts()
	..()

	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 1500 * B.rating

/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O,/obj/item/seeds))
		return 1
	return 0

/obj/machinery/smartfridge/seeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	content_overlay = "smartfridge-petri"

/obj/machinery/smartfridge/seeds/accept_check(obj/item/O)
	if(istype(O,/obj/item/seeds))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."
	content_overlay = "smartfridge-chem"

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/storage/pill_bottle))
		return TRUE
	if(!istype(O,/obj/item/weapon/reagent_containers))
		return FALSE
	if(istype(O,/obj/item/weapon/reagent_containers/pill)) // empty pill prank ok
		return TRUE
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return FALSE
	if(istype(O,/obj/item/weapon/reagent_containers/syringe) || istype(O,/obj/item/weapon/reagent_containers/glass/bottle) || istype(O,/obj/item/weapon/reagent_containers/glass/beaker) || istype(O,/obj/item/weapon/reagent_containers/spray))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/secure/extract
	name = "Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts."
	req_access = list(access_xenobiology)
	content_overlay = "smartfridge-slime"

/obj/machinery/smartfridge/secure/extract/accept_check(obj/item/O)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay
	name = "Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	req_one_access = list(access_medical, access_chemistry)
	content_overlay = "smartfridge-chem"

/obj/machinery/smartfridge/secure/medbay/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass))
		return 1
	if(istype(O,/obj/item/weapon/storage/pill_bottle))
		return 1
	if(istype(O,/obj/item/weapon/reagent_containers/pill))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay/pharmacy
	name = "Pharmacy Refrigerator"
	desc = "A refrigerated storage unit for medicines. Medical staff can dispense freely. Others must purchase items at prices set by the chemist."
	req_one_access = list(access_medical, access_chemistry)

	var/list/prices = list()
	var/vend_pending = FALSE
	var/pending_item_name = ""
	var/pending_item_index = 0
	var/pending_amount = 0
	var/pending_price = 0

/obj/machinery/smartfridge/secure/medbay/pharmacy/proc/can_change_price(mob/user)
	if(issilicon(user))
		return TRUE
	var/obj/item/weapon/card/id/ID = get_user_card(user)
	if(!ID)
		return FALSE
	for(var/acc in ID.access)
		if(acc == access_chemistry || acc == access_cmo)
			return TRUE
	return FALSE

/obj/machinery/smartfridge/secure/medbay/pharmacy/proc/reset_pending()
	vend_pending = FALSE
	pending_item_name = ""
	pending_item_index = 0
	pending_amount = 0
	pending_price = 0

/obj/machinery/smartfridge/secure/medbay/pharmacy/attackby(obj/item/O, mob/user)
	if(vend_pending)
		if(istype(O, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/C = O
			try_payment(user, C)
			return

		if(istype(O, /obj/item/device/pda))
			var/obj/item/device/pda/P = O
			var/obj/item/weapon/card/id/C = P.GetID()
			if(C)
				try_payment(user, C)
			else
				to_chat(user, "<span class='warning'>No ID card found in the PDA!</span>")
			return

		to_chat(user, "<span class='warning'>Please swipe your ID card to pay [pending_price] credits.</span>")
		return
	return ..()

/obj/machinery/smartfridge/secure/medbay/pharmacy/proc/try_payment(mob/user, obj/item/weapon/card/id/C)
	if(!vend_pending || !C)
		return
	visible_message("<span class='info'>[user] swipes a card through [src].</span>")
	playsound(src, 'sound/machines/use_card.ogg', VOL_EFFECTS_MASTER)
	var/datum/money_account/D = get_account(C.associated_account_number)
	var/datum/money_account/S = global.department_accounts["Medical"]
	if(!D || !S)
		to_chat(user, "<span class='warning'>Unable to access your money account!</span>")
		return
	D = attempt_account_access_with_user_input(C.associated_account_number, ACCOUNT_SECURITY_LEVEL_MAXIMUM, user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!D)
		to_chat(user, "<span class='warning'>Wrong account PIN!</span>")
		return
	if(pending_price > D.money)
		to_chat(user, "<span class='warning'>You don't have enough money!</span>")
		return
	var/tax = 0
	if(S in global.department_accounts)
		tax = round(pending_price * SSeconomy.tax_vendomat_sales * 0.01)
		charge_to_account(global.station_account.account_number, global.station_account.owner_name, "Налог на продажу в вендомате", src.name, tax)
	charge_to_account(D.account_number, "[S.owner_name] (via [src.name])", "Покупка: [pending_item_name]", src.name, -pending_price)
	charge_to_account(S.account_number, S.owner_name, "Продажа: [pending_item_name]", src.name, pending_price - tax)
	do_vend()

/obj/machinery/smartfridge/secure/medbay/pharmacy/proc/get_user_card(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/weapon/card/id/ID = H.get_idcard()
		if(!ID)
			for(var/obj/item/I in H.get_hand_slots())
				if(!I)
					continue
				ID = I.GetID()
				if(ID)
					break
		return ID
	return null

/obj/machinery/smartfridge/secure/medbay/pharmacy/proc/do_vend()
	var/K = item_quants[pending_item_index]
	var/count = item_quants[K]
	if(count > 0)
		item_quants[K] = max(count - pending_amount, 0)
		var/i = pending_amount
		for(var/obj/O in contents)
			if(O.name == K)
				O.loc = loc
				i--
				if(i <= 0)
					break
	reset_pending()
	SStgui.update_uis(src)

/obj/machinery/smartfridge/secure/medbay/pharmacy/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PharmacyFridge", name)
		ui.open()

/obj/machinery/smartfridge/secure/medbay/pharmacy/tgui_data(mob/user)
	var/list/data = list(
		"contents" = null,
		"secure" = TRUE,
		"vend_pending" = vend_pending,
		"pending_price" = pending_price,
		"pending_item" = pending_item_name,
	)

	var/list/items[0]
	for(var/i = 1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if(count > 0)
			var/price = prices[K]
			items.Add(list(list(
				"display_name" = html_encode(capitalize(K)),
				"vend" = i,
				"quantity" = count,
				"price" = price
			)))

	if(items.len > 0)
		data["contents"] = items

	if(allowed(user))
		data["is_staff"] = TRUE
	else
		data["is_staff"] = FALSE

	data["can_set_prices"] = can_change_price(user)

	return data

/obj/machinery/smartfridge/secure/medbay/pharmacy/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "set_price")
		if(!can_change_price(usr))
			return FALSE
		var/index = text2num(params["index"])
		var/price = text2num(params["price"])
		if(index && index <= length(item_quants))
			var/K = item_quants[index]
			if(price >= 0)
				prices[K] = price
				SStgui.update_uis(src)
				return TRUE
		return FALSE

	if(action == "buy")
		if(vend_pending)
			return FALSE
		var/index = text2num(params["index"])
		var/amount = text2num(params["amount"])
		if(index && index <= length(item_quants))
			var/K = item_quants[index]
			var/count = item_quants[K]
			var/price = prices[K]
			if(isnull(price) || count <= 0)
				return FALSE
			if(price <= 0)
				return FALSE
			vend_pending = TRUE
			pending_item_name = K
			pending_item_index = index
			pending_amount = min(amount, count)
			pending_price = price * pending_amount
			var/obj/item/weapon/card/id/ID = get_user_card(usr)
			if(ID)
				try_payment(usr, ID)
			else
				SStgui.update_uis(src)
			return TRUE
		return FALSE

	if(action == "cancel_buy")
		reset_pending()
		SStgui.update_uis(src)
		return TRUE

	return FALSE

/obj/machinery/smartfridge/secure/virology
	name = "Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	req_access = list(access_virology)
	content_overlay = "smartfridge-viro"

/obj/machinery/smartfridge/secure/virology/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/beaker/vial))
		return 1
	if(istype(O,/obj/item/weapon/virusdish))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry/virology
	name = "Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	content_overlay = "smartfridge-viro"


/obj/machinery/smartfridge/drinks
	name = "Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	content_overlay = "smartfridge-drink"

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks) || istype(O,/obj/item/weapon/reagent_containers/food/condiment))
		return 1

/obj/machinery/smartfridge/secure/bluespace
	name = "Bluespace Storage"
	desc = "Очень вместительное хранилище вещей с гравировкой BB-tech"
	icon_state = "bluespace"
	icon_on = "bluespace"
	icon_off = "bluespace-off"

/obj/machinery/smartfridge/secure/bluespace/accept_check(obj/item/O)
	if(istype(O, /obj/item/weapon/storage/bag) || istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))
		return FALSE
	if(isitem(O))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/secure/bluespace/atom_init()
	. = ..()
	wires = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smartfridge/secure/bluespace(null, type)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/smartfridge/secure/bluespace/create_fridge_states()
	return

/obj/machinery/smartfridge/secure/bluespace/update_icon()
	if(stat & BROKEN)
		icon_state = "bluespace-broken"

/obj/machinery/smartfridge/process()
	if(!src.ispowered)
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		throw_item()

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
	update_power_use()

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, icon_off, icon_on, O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	default_deconstruction_crowbar(O)

	if(is_wire_tool(O) && panel_open && wires.interact(user))
		return

	if(!src.ispowered)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(accept_check(O))
		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return
		else
			user.remove_from_mob(O)
			O.loc = src
			if(item_quants[O.name])
				item_quants[O.name]++
			else
				item_quants[O.name] = 1
			user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
								 "<span class='notice'>You add \the [O] to \the [src].</span>")

			nanomanager.update_uis(src)

	else if(istype(O, /obj/item/weapon/storage)) // fastload from userstorage
		if(istype(O, /obj/item/weapon/storage/lockbox))
			var/obj/item/weapon/storage/lockbox/L = O
			if(L.locked)
				to_chat(user, "<span class='notice'>\The [L] is locked.</span>")
				return
		var/obj/item/weapon/storage/S = O
		var/item_loaded = 0
		for(var/obj/I in S.contents)
			if(accept_check(I))
				if(contents.len >= max_n_of_items)
					to_chat(user, "<span class='notice'>\The [src] is full.</span>")
					return
				else
					S.remove_from_storage(I,src)
					if(item_quants[I.name])
						item_quants[I.name]++
					else
						item_quants[I.name] = 1
					item_loaded++

		if(item_loaded)
			user.visible_message( \
				"<span class='notice'>[user] loads \the [src] with \the [S].</span>", \
				"<span class='notice'>You load \the [src] with \the [S].</span>")
			if(S.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

		nanomanager.update_uis(src)
		return
	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return

/obj/machinery/smartfridge/secure/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	locked = -1
	to_chat(user, "You short out the product lock on [src].")
	return TRUE

/obj/machinery/smartfridge/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	return 0

/obj/machinery/smartfridge/attack_hand(mob/user)
	if(!issilicon(user) && !isobserver(user) && seconds_electrified)
		if(shock(user, 100))
			return

	return ..()

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/smartfridge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartFridge", name)
		ui.open()

/obj/machinery/smartfridge/tgui_data(mob/user)
	var/list/data = list(
	"contents" = null,
	"locked" = locked,
	"secure" = istype(src,/obj/machinery/smartfridge/secure)
	)

	var/list/items[0]
	for (var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if (count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if (items.len > 0)
		data["contents"] = items
	return data

/obj/machinery/smartfridge/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if (action == "vend")
		var/index = text2num(params["index"])
		var/amount = text2num(params["amount"])
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
	throw_item.throw_at(target,16,3,src)
	visible_message("<span class='warning'><b>[src] launches [throw_item.name] at [target.name]!</b></span>")
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

/obj/machinery/smartfridge/secure/tgui_act(action, params)
	if(!allowed(usr) && !emagged && locked != -1 && action == "vend")
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return FALSE
	return ..()
