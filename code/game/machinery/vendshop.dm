/datum/data/shop_product
	name = "generic"
	var/owner
	var/list/objects = list()
	var/price = 0

/obj/machinery/vendshop
	name = "Shop"
	desc = "A generic shop."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	var/icon_deny

	layer = 2.9
	anchored = 1
	density = 1
	var/light_range_on = 3
	var/light_power_on = 1
	light_color = "#77beda"
	var/seconds_electrified = 0
	var/vend_delay = 10
	var/vend_ready = TRUE
	var/station_tax = 10
	var/head_tax = 10
	var/datum/data/shop_product/buying_product = null
	var/head_earning = 0
	var/list/earnings = list()

	var/user_name = null
	var/user_cansell = FALSE
	var/user_hasfullaccess = FALSE
	var/auto_logout = 0
	var/auto_logout_time = 60

	var/list/products = list()
	var/list/access_cansell = list(access_cargo)
	var/list/access_fullaccess = list(access_qm)
	var/list/whitelist = list()
	var/list/blacklist = list()

/obj/machinery/vendshop/atom_init()
	. = ..()
	power_change()

/obj/machinery/vendshop/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		set_light(0)
	else
		if( powered() & src.anchored )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			set_light(light_range_on, light_power_on)
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER
				set_light(0)

/obj/machinery/vendshop/Destroy()
	//QDEL_NULL(wires)
	//QDEL_NULL(coin)
	return ..()

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
				spawn(0)
					//src.malfunction()
					return
				return
		else
	return

/obj/machinery/vendshop/blob_act()
	if (prob(50))
		spawn(0)
			//src.malfunction()
			qdel(src)
		return

	return

/obj/machinery/vendshop/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(seconds_electrified && !issilicon(user) && !isobserver(user))
		if(shock(user, 100))
			return


	/*var/dat
	dat += "<h3>Select an item</h3>"
	dat += "<div class='statusDisplay'>"

	dat += "<font color = 'red'>No product loaded!</font>"

	dat += "</div>"

	var/datum/browser/popup = new(user, "window=vending", "[name]", 450, 500)
	popup.set_content(dat)
	popup.open()*/

	var/data[0]
	data["user_name"] = user_name
	data["user_cansell"] = user_cansell
	data["user_hasfullaccess"] = user_hasfullaccess
	data["contents"] = null
	data["buying_product"] = null
	if(buying_product)
		data["buying_product"] = buying_product.name
	data["head_earning"] = head_earning
	data["station_tax"] = station_tax
	data["head_tax"] = head_tax
	data["earnings"] = 0
	if(earnings[user_name])
		data["earnings"] = earnings[user_name]
	/*data["contents"] = null
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
		data["contents"] = items*/
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

	auto_logout = auto_logout_time

	if (href_list["close"])
		user.unset_machine()
		ui.close()
		return FALSE

	if (href_list["logout"])
		user_name = null
		user_cansell = FALSE
		user_hasfullaccess = FALSE
		return TRUE

	if (href_list["vend"] && vend_ready)
		var/datum/data/shop_product/selected_product = locate(href_list["vend"])
		vend_product(selected_product)
		return TRUE

	if (href_list["buy"] && vend_ready)
		var/datum/data/shop_product/selected_product = locate(href_list["buy"])
		buying_product = selected_product
		return TRUE

	if (href_list["cancelbuying"])
		buying_product = null
		return TRUE

	if (href_list["cashout"])
		if(user_name && user_cansell && earnings[user_name]>0)
			playsound(src, 'sound/machines/chime.ogg', 50, 1)
			var/obj/item/weapon/spacecash/ewallet/E = new /obj/item/weapon/spacecash/ewallet(loc)
			E.worth = earnings[user_name]
			E.owner_name = user_name
			earnings[user_name] = 0
		return TRUE

	if (href_list["cashouthead"])
		if(user_name && user_hasfullaccess && head_earning>0)
			playsound(src, 'sound/machines/chime.ogg', 50, 1)
			var/obj/item/weapon/spacecash/ewallet/E = new /obj/item/weapon/spacecash/ewallet(loc)
			E.worth = head_earning
			E.owner_name = user_name
			head_earning = 0
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

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	if(auto_logout > 0 && user_name)
		auto_logout -= 1

		if(auto_logout == 0)
			user_name = null
			user_cansell = FALSE
			user_hasfullaccess = FALSE
			nanomanager.update_uis(src)

	return

/obj/machinery/vendshop/proc/accept_check(obj/item/O)
	if(whitelist.len > 0)
		var/found = FALSE
		for(var/X in whitelist)
			if(istype(O,X))
				found = TRUE
				break
		if(!found)
			return FALSE

	for(var/X in blacklist)
		if(istype(O,X))
			return FALSE
	return TRUE

/obj/machinery/vendshop/attackby(obj/item/O, mob/user)
	if(!powered())
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(istype(O, /obj/item/device/pda) && O.GetID())
		var/obj/item/weapon/card/I = O.GetID()
		scan_card(I)

	else if(istype(O, /obj/item/weapon/card))
		var/obj/item/weapon/card/I = O
		scan_card(I)

	else if(accept_check(O))
		if(!user_name)
			to_chat(user, "<span class='notice'>\The [src] beeps and a message 'Authentication required' shows up.</span>")
			return
		if(!user_cansell)
			to_chat(user, "<span class='notice'>\The [src] beeps and a message 'Access denied' shows up.</span>")
			return

		var/price
		if(!has_shop_item(O, user_name))
			var/confirm = alert("Are you sure you want to sell this item?", "Confirm Selling", "Yes", "No")
			if(confirm != "Yes")
				return
			auto_logout = auto_logout_time

			var/amt_temp = input(usr, "Enter the cost of item.", "How much will item cost?", price) as num|null
			if(!isnum(amt_temp) || amt_temp<0)
				return
			price = Clamp(round(amt_temp), 0, 100000)
		if(!in_range(user, src) || O.loc != user)
			return
		user.remove_from_mob(O)
		add_shop_item(O, user_name, price)
		user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
						     "<span class='notice'>You add \the [O] to \the [src].")
		nanomanager.update_uis(src)
	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return

/obj/machinery/vendshop/proc/scan_card(obj/item/weapon/card/I)
	if (istype(I, /obj/item/weapon/card/id/guest))
		return

	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = I

		if(!buying_product)
			visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
			user_name = ID.registered_name
			user_cansell = FALSE
			user_hasfullaccess = FALSE
			auto_logout = auto_logout_time

			req_one_access = access_cansell
			if(check_access(I))
				user_cansell = TRUE
			req_one_access = access_fullaccess
			if(check_access(I))
				user_hasfullaccess = TRUE
				user_cansell = TRUE
			req_one_access = null

			nanomanager.update_uis(src)
		else if(vend_ready)
			visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
			var/station_cut = round(buying_product.price * (station_tax / 100))
			var/money_left = buying_product.price - station_cut
			var/head_cut = round(money_left * (head_tax / 100))
			money_left = money_left - head_cut

			head_earning += head_cut
			if(!earnings[buying_product.owner])
				earnings[buying_product.owner] = 0
			earnings[buying_product.owner] += money_left

			if(vendor_account)
				var/datum/money_account/D = get_account(ID.associated_account_number)
				var/attempt_pin = 0
				if(D)
					if(D.security_level > 0)
						attempt_pin = input("Enter pin code", "Vendor transaction") as num
					if(attempt_pin)
						D = attempt_account_access(ID.associated_account_number, attempt_pin, 2)
					if(D)
						var/transaction_amount = station_cut
						if(buying_product.price <= D.money)

							//transfer the money
							D.money -= buying_product.price
							vendor_account.money += transaction_amount

							//create entries in the two account transaction logs
							var/datum/transaction/T = new()
							T.target_name = "[vendor_account.owner_name] (via [src.name])"
							T.purpose = "Purchase of [buying_product.name] from [buying_product.owner]"
							if(transaction_amount > 0)
								T.amount = "([transaction_amount])"
							else
								T.amount = "[transaction_amount]"
							T.source_terminal = src.name
							T.date = current_date_string
							T.time = worldtime2text()
							D.transaction_log.Add(T)
							//
							T = new()
							T.target_name = D.owner_name
							T.purpose = "Purchase of [buying_product.name] from [buying_product.owner]"
							T.amount = "[transaction_amount]"
							T.source_terminal = src.name
							T.date = current_date_string
							T.time = worldtime2text()
							vendor_account.transaction_log.Add(T)

							// Vend the item
							vend_product(buying_product)
							buying_product = null
							nanomanager.update_uis(src)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
					else
						to_chat(usr, "[bicon(src)]<span class='warning'>You entered wrong account PIN!</span>")
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>Unable to find your money account!</span>")
			else
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access account. Check security settings and try again.</span>")

/obj/machinery/vendshop/proc/add_shop_item(obj/item/O, seller_name, price = 100)
	if(!seller_name || !O)
		return FALSE

	for(var/datum/data/shop_product/product in products)
		if(product.name == O.name && product.owner == seller_name)
			product.objects += O
			O.forceMove(src)
			return TRUE
	var/datum/data/shop_product/product = new /datum/data/shop_product
	product.name = O.name
	product.owner = seller_name
	product.price = price
	product.objects = list(O)
	O.forceMove(src)
	products += product
	return TRUE

/obj/machinery/vendshop/proc/has_shop_item(obj/item/O, seller_name)
	if(!seller_name || !O)
		return FALSE
	for(var/datum/data/shop_product/product in products)
		if(product.name == O.name && product.owner == seller_name)
			return TRUE
	return FALSE



/obj/machinery/vendshop/med
	name = "Medical Shop"
	desc = "A generic shop."
	icon_state = "med"
	icon_deny = "med-deny"
	light_color = "#e6fff2"

	access_cansell = list(access_medical)
	access_fullaccess = list(access_cmo)
	whitelist = list(/obj/item/weapon/reagent_containers/glass, /obj/item/weapon/storage/firstaid, /obj/item/roller,
					 /obj/item/clothing/mask/surgical, /obj/item/clothing/gloves/latex, /obj/item/weapon/reagent_containers/hypospray,
					 /obj/item/clothing/glasses/hud/health, /obj/item/stack/medical, /obj/item/weapon/reagent_containers/pill,
					 /obj/item/device/healthanalyzer, /obj/item/weapon/reagent_containers/syringe, /obj/item/bodybag,
					 /obj/item/weapon/storage/belt/medical, /obj/item/weapon/medical/teleporter, /obj/item/clothing/suit/straight_jacket,
					 /obj/item/weapon/cane, /obj/item/clothing/accessory/stethoscope, /obj/item/clothing/mask/muzzle,
					 /obj/item/clothing/glasses/regular, /obj/item/weapon/reagent_containers/glass/beaker,
					 /obj/item/weapon/storage/pill_bottle, /obj/item/clothing/suit/storage/labcoat, /obj/item/weapon/grenade/chem_grenade)
	blacklist = list()