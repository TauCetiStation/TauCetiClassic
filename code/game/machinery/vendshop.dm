/datum/data/shop_product
	name = "generic"
	var/owner
	var/list/objects = list()
	var/price = 0

/obj/machinery/vendshop
	name = "Shop"
	desc = "A generic shop."
	icon = 'icons/obj/vendshop.dmi'
	icon_state = "FreeMarket"

	layer = 2.9
	anchored = TRUE
	density = 1
	var/light_range_on = 3
	var/light_power_on = 1
	light_color = "#7cb4d9"
	var/seconds_electrified = 0
	var/shoot_inventory = FALSE
	var/scan_id = TRUE // only people with access can sell
	var/productcheck = TRUE // checks if we can sell these kind of items
	var/maintenance_protocols = FALSE
	var/vend_delay = 10
	var/vend_ready = TRUE
	var/station_tax = 10
	var/head_tax = 10
	var/datum/data/shop_product/buying_product = null
	var/department_earning = 0
	var/list/earnings = list()
	var/department = "Civilian"
	var/max_product_types_per_person = 3
	var/max_products_per_type = 5
	var/datum/wires/vendshop/wires = null

	var/user_name = null
	var/user_cansell = FALSE
	var/user_hasfullaccess = FALSE
	var/datum/money_account/user_account = null
	var/obj/item/weapon/card/held_card = null

	var/list/products = list()
	var/list/access_cansell = list(access_cargo)
	var/list/access_fullaccess = list(access_qm)
	var/list/whitelist = list()
	var/list/blacklist = list()
	var/list/global_blacklist = list(/obj/item/weapon/grab, /obj/item/weapon/holder, /obj/item/device/pda)

/obj/machinery/vendshop/atom_init()
	. = ..()
	wires = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/vendshop(null)

	power_change()

/obj/machinery/vendshop/power_change()
	if(stat & BROKEN)
		set_light(0)
	else
		if( powered() & anchored )
			stat &= ~NOPOWER
			set_light(light_range_on, light_power_on)
		else
			stat |= NOPOWER
			set_light(0)

	update_icon()

/obj/machinery/vendshop/update_icon()
	overlays.Cut()
	if( powered() && anchored  && !(stat & BROKEN))
		icon_state = initial(icon_state)

		if(emagged)
			overlays += image(icon, "broken")
	else
		icon_state = "[initial(icon_state)]-off"

	if(panel_open)
		overlays += image(icon, "panel")

/obj/machinery/vendshop/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/vendshop/deconstruction()
	for(var/atom/movable/A in contents)
		A.forceMove(loc)

/obj/machinery/vendshop/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return

/obj/machinery/vendshop/blob_act()
	if (prob(50))
		spawn(0)
			qdel(src)

/obj/machinery/vendshop/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(seconds_electrified && !issilicon(user) && !isobserver(user))
		if(shock(user, 100))
			return

	var/data[0]
	data["user_name"] = user_name
	data["user_cansell"] = user_cansell || !scan_id || emagged
	data["user_hasfullaccess"] = user_hasfullaccess || emagged
	data["contents"] = null
	data["maintenance_protocols"] = maintenance_protocols
	data["buying_product"] = null
	if(buying_product)
		data["buying_product"] = buying_product.name
	data["department_earning"] = department_earning
	data["station_tax"] = station_tax
	data["head_tax"] = head_tax
	data["earnings"] = 0
	if(earnings[user_name])
		data["earnings"] = earnings[user_name]
	var/list/items[0]
	for(var/datum/data/shop_product/product in products)
		items += list(list("display_name" = capitalize(product.name), "owner" = product.owner, "price" = product.price, "quantity" = product.objects.len, "reference" = "\ref[product]"))

	if (items.len > 0)
		data["contents"] = items

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "vendshop.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/vendshop/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	if (href_list["close"])
		user.unset_machine()
		ui.close()
		return FALSE

	if (href_list["logout"])
		if(!held_card)
			return FALSE
		held_card.forceMove(loc)
		if(ishuman(user) && !user.get_active_hand())
			user.put_in_hands(held_card)
		held_card = null
		user_name = null
		user_cansell = FALSE
		user_hasfullaccess = FALSE
		user_account = null
		return TRUE

	if (href_list["vend"] && vend_ready)
		var/datum/data/shop_product/selected_product = locate(href_list["vend"])
		vend_product(selected_product)
		return TRUE

	if (href_list["buy"] && vend_ready)
		var/datum/data/shop_product/selected_product = locate(href_list["buy"])
		if(selected_product.price <= 0)
			vend_product(selected_product)
		else
			buying_product = selected_product
		return TRUE

	if (href_list["cancelbuying"])
		buying_product = null
		return TRUE

	if (href_list["togglemaintenance"])
		maintenance_protocols = !maintenance_protocols
		if(maintenance_protocols)
			visible_message("<span class='info'>[src]'s securing bolts are now exposed.</span>")
		else
			visible_message("<span class='info'>[src]'s securing bolts are now hidden.</span>")
		return TRUE

	if (href_list["transfer"])
		if(user_name && user_cansell && earnings[user_name]>0 && user_account)
			playsound(src, 'sound/machines/chime.ogg', 50, 1)
			visible_message("<span class='info'>[src] beeps.</span>")

			user_account.money += earnings[user_name]

			var/datum/transaction/T = new()
			T.target_name = "[user_name]"
			T.purpose = "Profits transfer"
			T.amount = "[earnings[user_name]]"
			T.source_terminal = src.name
			T.date = current_date_string
			T.time = worldtime2text()
			user_account.transaction_log.Add(T)

			earnings[user_name] = 0
		return TRUE

	if (href_list["changeheadtax"])
		var/amt_temp = input(usr, "Enter new tax (0-100).", "How much will the new tax be?", head_tax) as num|null
		if(!isnum(amt_temp) || amt_temp<0)
			return FALSE
		head_tax = Clamp(round(amt_temp), 0, 100)
		return TRUE

	if (href_list["changeprice"])
		var/datum/data/shop_product/selected_product = locate(href_list["changeprice"])
		var/amt_temp = input(usr, "Enter the cost of item.", "How much will item cost?", price) as num|null
		if(!isnum(amt_temp))
			return FALSE
		selected_product.price = Clamp(round(amt_temp), 0, 100000)
		return TRUE

/obj/machinery/vendshop/proc/vend_product(var/datum/data/shop_product/product)
	if(!vend_ready)
		return
	vend_ready = FALSE
	var/obj/item/O = product.objects[1]
	product.objects -= O
	if(product.objects.len == 0)
		products -= product
	spawn(src.vend_delay)
		O.forceMove(loc)
		playsound(src, 'sound/items/vending.ogg', 50, 1, 1)
		vend_ready = TRUE
		return


/obj/machinery/vendshop/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/vendshop/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	if(shoot_inventory && prob(2))
		throw_item()

	return

/obj/machinery/vendshop/proc/throw_item()
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	var/datum/data/shop_product/product = pick(products)
	if(!product)
		return 0

	var/obj/throw_item = pick(product.objects)
	if(!throw_item)
		return 0

	product.objects -= throw_item
	if(product.objects.len == 0)
		products -= product

	throw_item.forceMove(loc)
	throw_item.throw_at(target, 16, 3)
	visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")
	return 1

/obj/machinery/vendshop/proc/accept_check(obj/item/O)
	if(!productcheck)
		for(var/X in global_blacklist)
			if(istype(O,X))
				return FALSE
		return TRUE

	if(whitelist.len > 0)
		var/found = FALSE
		for(var/X in whitelist)
			if(istype(O,X))
				found = TRUE
				break
		if(!found)
			return FALSE

	for(var/X in (blacklist + global_blacklist))
		if(istype(O,X))
			return FALSE
	return TRUE

/obj/machinery/vendshop/attackby(obj/item/O, mob/user)
	if (istype(O, /obj/item/weapon/card/emag))
		emagged = TRUE
		to_chat(user, "<span class='notice'>You short out the security system of [src]</span>")
		update_icon()
		var/obj/item/weapon/card/emag/emag = O
		emag.uses--
		return

	if(istype(O, /obj/item/weapon/screwdriver) && anchored && maintenance_protocols)
		panel_open = !panel_open
		to_chat(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		update_icon()
		nanomanager.update_uis(src)
		return

	if(is_wire_tool(O) && panel_open && wires.interact(user))
		return

	if(maintenance_protocols && default_unfasten_wrench(user, O))
		power_change()
		return

	if(maintenance_protocols && default_pry_open(O))
		return

	if(maintenance_protocols && default_deconstruction_crowbar(O))
		return

	if(!powered() || !anchored)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(istype(O, /obj/item/device/pda) && O.GetID())
		var/obj/item/weapon/card/I = O.GetID()
		scan_card(I, ispda = TRUE)

	else if(istype(O, /obj/item/weapon/card))
		var/obj/item/weapon/card/I = O
		scan_card(I)

	else if(accept_check(O))
		if(!user_name)
			to_chat(user, "<span class='notice'>\The [src] beeps and a message 'Authentication required' shows up.</span>")
			return
		if(!user_cansell && scan_id)
			to_chat(user, "<span class='notice'>\The [src] beeps and a message 'Access denied' shows up.</span>")
			return

		var/price
		if(!has_shop_item(O, user_name))
			if(!user_hasfullaccess && count_shop_items_types(user_name) >= max_product_types_per_person) // too much different items for one person
				to_chat(user, "<span class='notice'>\The [src] beeps and a message 'Limit reached' shows up.</span>")
				return

			var/confirm = alert("Are you sure you want to sell this item?", "Confirm Selling", "Yes", "No")
			if(confirm != "Yes")
				return

			var/amt_temp = input(usr, "Enter the cost of item.", "How much will item cost?", price) as num|null
			if(!isnum(amt_temp) || amt_temp<0)
				return
			price = Clamp(round(amt_temp), 0, 100000)
		else if(!user_hasfullaccess && count_shop_items(O, user_name) >= max_products_per_type) // too much of the same item
			to_chat(user, "<span class='notice'>\The [src] beeps and a message 'Limit reached' shows up.</span>")
			return

		if(!in_range(user, src) || O.loc != user)
			return
		user.remove_from_mob(O)
		if(!O)
			return
		add_shop_item(O, user_name, price)
		user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
						     "<span class='notice'>You add \the [O] to \the [src].")
		nanomanager.update_uis(src)
	else
		to_chat(user, "<span class='notice'>\The [src] refuses [O].</span>")
		return

/obj/machinery/vendshop/proc/scan_card(obj/item/weapon/card/I, ispda = FALSE)
	if (istype(I, /obj/item/weapon/card/id/guest))
		return

	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = I

		if(!buying_product)
			if(ispda || held_card)
				return

			var/datum/money_account/D = get_account(ID.associated_account_number)
			if(!D)
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to find your money account!</span>")
				return

			usr.drop_from_inventory(I)
			I.forceMove(src)
			held_card = I
			visible_message("<span class='info'>[usr] inserts an id into [src].</span>")
			user_name = ID.registered_name
			user_cansell = FALSE
			user_hasfullaccess = FALSE
			user_account = D

			req_one_access = access_cansell
			if(check_access(I) || !access_cansell.len)
				user_cansell = TRUE
			req_one_access = access_fullaccess
			if(check_access(I) || !access_fullaccess.len)
				user_hasfullaccess = TRUE
				user_cansell = TRUE
			req_one_access = null

			nanomanager.update_uis(src)
		else if(vend_ready)
			visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
			var/station_cut = round(buying_product.price * (station_tax / 100))
			var/money_left = buying_product.price - station_cut
			var/department_cut = round(money_left * (head_tax / 100))
			money_left = money_left - department_cut

			department_earning += department_cut
			if(!earnings[buying_product.owner])
				earnings[buying_product.owner] = 0
			earnings[buying_product.owner] += money_left

			if(!station_account)
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access account. Check security settings and try again.</span>")
				return
			var/datum/money_account/D = get_account(ID.associated_account_number)
			if(!D)
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to find your money account!</span>")
				return

			var/attempt_pin = 0
			if(D.security_level > 0)
				attempt_pin = input("Enter pin code", "Vendor transaction") as num
			if(attempt_pin)
				D = attempt_account_access(ID.associated_account_number, attempt_pin, 2)
			if(!D)
				to_chat(usr, "[bicon(src)]<span class='warning'>You entered wrong account PIN!</span>")
				return
			if(buying_product.price > D.money)
				to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
				return

			//transfer the money
			D.money -= buying_product.price
			station_account.money += station_cut
			department_accounts[department].money += department_cut

			//card transaction logs
			var/datum/transaction/T = new()
			T.target_name = "[station_account.owner_name] (via [src.name])"
			T.purpose = "Purchase of [buying_product.name]"
			T.amount = "([buying_product.price])"
			T.source_terminal = src.name
			T.date = current_date_string
			T.time = worldtime2text()
			D.transaction_log.Add(T)
			//station account transaction logs
			T = new()
			T.target_name = D.owner_name
			T.purpose = "Purchase of [buying_product.name]"
			T.amount = "[station_cut]"
			T.source_terminal = src.name
			T.date = current_date_string
			T.time = worldtime2text()
			station_account.transaction_log.Add(T)
			//department account transaction logs
			T = new()
			T.target_name = D.owner_name
			T.purpose = "Purchase of [buying_product.name]"
			T.amount = "[department_cut]"
			T.source_terminal = src.name
			T.date = current_date_string
			T.time = worldtime2text()
			department_accounts[department].transaction_log.Add(T)

			// Vend the item
			vend_product(buying_product)
			buying_product = null
			nanomanager.update_uis(src)

/obj/machinery/vendshop/proc/get_item_name(obj/item/O) // some items require special names
	if(!O)
		return null
	var/item_name = O.name
	if(istype(O,/obj/item/weapon/paper))
		item_name = "[item_name] (paper)"

	return item_name

/obj/machinery/vendshop/proc/add_shop_item(obj/item/O, seller_name, price = 100)
	if(!seller_name || !O)
		return FALSE

	var/item_name = get_item_name(O)

	for(var/datum/data/shop_product/product in products)
		if(product.name == item_name && product.owner == seller_name)
			product.objects += O
			O.forceMove(src)
			return TRUE
	var/datum/data/shop_product/product = new /datum/data/shop_product
	product.name = item_name
	product.owner = seller_name
	product.price = price
	product.objects = list(O)
	O.forceMove(src)
	products += product
	return TRUE

/obj/machinery/vendshop/proc/has_shop_item(obj/item/O, seller_name) // does this guy sells these kind of items
	if(!seller_name || !O)
		return FALSE

	var/item_name = get_item_name(O)

	for(var/datum/data/shop_product/product in products)
		if(product.name == item_name && product.owner == seller_name)
			return TRUE
	return FALSE

/obj/machinery/vendshop/proc/count_shop_items(obj/item/O, seller_name) // how much of these items this guy sells
	if(!seller_name || !O)
		return 0

	var/item_name = get_item_name(O)

	for(var/datum/data/shop_product/product in products)
		if(product.name == item_name && product.owner == seller_name)
			return product.objects.len
	return 0

/obj/machinery/vendshop/proc/count_shop_items_types(seller_name) // how much different types of products this guy sells
	if(!seller_name)
		return FALSE

	var/count = 0
	for(var/datum/data/shop_product/product in products)
		if(product.owner == seller_name)
			count++
	return count

// Requires medbey access, can sell only medical items
/obj/machinery/vendshop/med
	name = "Medbay Shop"
	desc = "A store that sells health care products and medicine. Also drugs"
	icon_state = "Med"
	light_color = "#9fe892"

	department = "Medical"
	access_cansell = list(access_medical)
	access_fullaccess = list(access_cmo)
	whitelist = list(/obj/item/weapon/reagent_containers/glass, /obj/item/weapon/storage/firstaid, /obj/item/roller,
					 /obj/item/clothing/mask/surgical, /obj/item/clothing/gloves/latex, /obj/item/weapon/reagent_containers/hypospray,
					 /obj/item/clothing/glasses/hud/health, /obj/item/stack/medical, /obj/item/weapon/reagent_containers/pill,
					 /obj/item/device/healthanalyzer, /obj/item/weapon/reagent_containers/syringe, /obj/item/bodybag,
					 /obj/item/weapon/storage/belt/medical, /obj/item/weapon/medical/teleporter, /obj/item/clothing/suit/straight_jacket,
					 /obj/item/weapon/cane, /obj/item/clothing/accessory/stethoscope, /obj/item/clothing/mask/muzzle,
					 /obj/item/clothing/glasses/regular, /obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/paper,
					 /obj/item/weapon/storage/pill_bottle, /obj/item/clothing/suit/storage/labcoat, /obj/item/weapon/grenade/chem_grenade)
	blacklist = list()

	max_product_types_per_person = 10
	max_products_per_type = 10

// Requires cargo access, can sell anything
/obj/machinery/vendshop/cargo
	name = "Cargo Shop"
	desc = "Sells any products that were imported by the cargo shuttle and found inside huge trash piles. Does NOT sells enslaved tajarans!"
	icon_state = "Cargo"
	light_color = "#f08f18"

	department = "Cargo"
	access_cansell = list(access_cargo)
	access_fullaccess = list(access_hop)
	whitelist = list()
	blacklist = list()

	max_product_types_per_person = 10
	max_products_per_type = 10

// Requires research access, can sell anything
/obj/machinery/vendshop/science
	name = "Science Shop"
	desc = "Sells anything that your scientists have come up with. Probably only garbage"
	icon_state = "Science"
	light_color = "#7cb4d9"

	department = "Science"
	access_cansell = list(access_research)
	access_fullaccess = list(access_rd)
	whitelist = list()
	blacklist = list()

	max_product_types_per_person = 10
	max_products_per_type = 10

// Requires kitchen, bar or hydroponics access, can sell only food
/obj/machinery/vendshop/food
	name = "Food Shop"
	desc = "Sells a variety of drinks and probably poisoned food. Don't choke on the prices!"
	icon_state = "Kitchen"
	light_color = "#7cb4d9"

	department = "Civilian"
	access_cansell = list(access_kitchen, access_bar, access_hydroponics)
	access_fullaccess = list(access_hop)
	whitelist = list(/obj/item/weapon/reagent_containers/food, /obj/item/weapon/tray)
	blacklist = list()

	max_product_types_per_person = 10
	max_products_per_type = 10

// no access required, can sell anything
/obj/machinery/vendshop/community
	name = "Community Shop"
	desc = "Buy and sell anything your greedy soul desires"
	icon_state = "FreeMarket"
	light_color = "#7cb4d9"

	department = "Civilian"
	access_cansell = list()
	access_fullaccess = list(access_hop)
	whitelist = list()
	blacklist = list()

	max_product_types_per_person = 3 // nerfed very hard so people dont sell the whole station
	max_products_per_type = 3