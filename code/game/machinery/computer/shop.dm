/obj/machinery/computer/shop
	name = "Ordering terminal"
	desc = "Заказ предметов для отдела."
	icon_state = "shop"
	state_broken_preset = "shopoff"
	state_nopower_preset = "shopoff"

	light_color = "#b88b2e"

	density = FALSE

	var/lastmode = 0
	var/ui_tick = 0
	var/nanoUI[0]

	var/department = ""
	var/mode = 1

	var/category
	var/list/shop_lots = list()
	var/list/shop_lots_paged = list()
	var/list/shop_lots_frontend = list()
	var/list/shopping_cart = list()
	var/category_shop_page = 1
	var/category_shop_per_page = 5


/obj/machinery/computer/shop/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	ui_tick++

	lastmode = mode

	var/title = "Терминал заказов."

	var/datum/money_account/MA = global.department_accounts[department]

	var/data[0]

	data["stationTime"] = worldtime2text()
	var/secLevelStr
	switch(get_security_level())
		if("green")
			secLevelStr = "<font color='green'><b>&#9899;</b></font>"
		if("blue")
			secLevelStr = "<font color='blue'><b>&#9899;</b></font>"
		if("red")
			secLevelStr = "<font color='red'><b>&#9899;</b></font>"
		if("delta")
			secLevelStr = "<font color='purple'><b>&Delta;</b></font>"
	data["securityLevel"] = secLevelStr

	data["mode"] = mode

	data["money"] = MA ? MA.money : "error"

	var/manifest = global.data_core.get_manifest()
	var/no_cargonauts = TRUE
	for(var/civ in manifest["civ"])
		if(civ["active"] == "Active" && (civ["rank"] in list("Quartermaster", "Cargo Technician")))
			no_cargonauts = FALSE
			break
	data["no_cargonauts"] = no_cargonauts
	// pass onlineshop data...
	var/list/categories_frontend = list()
	for(var/index in global.shop_categories)
		categories_frontend.len++
		categories_frontend[categories_frontend.len] = list("name" = index, "amount" = global.shop_categories[index])
	data["categories"] = categories_frontend

	data["category"] = category

	var/list/online_shop_lots_latest_frontend[3]
	for(var/i=1, i<=3, i++)
		var/datum/shop_lot/Lot = global.online_shop_lots_latest[i]
		if(!Lot)
			online_shop_lots_latest_frontend[i] = null
		else
			online_shop_lots_latest_frontend[i] = Lot.to_list()
	data["latest_lots"] = online_shop_lots_latest_frontend

	shop_lots = list()
	if(mode == 11)
		for(var/index in global.online_shop_lots_hashed)
			var/list/Lots = global.online_shop_lots_hashed[index]
			for(var/datum/shop_lot/Lot in Lots)
				if(Lot && Lot.category == category && !Lot.sold)
					shop_lots.len++
					shop_lots[shop_lots.len] = Lot.to_list()
					break

	shop_lots_frontend = list()
	if(shop_lots.len)
		var/lot_id = 1
		shop_lots_paged = list()
		shop_lots_paged.len++
		shop_lots_paged[shop_lots_paged.len] = list()
		for(var/list/Lot in shop_lots)
			var/list/part_list = shop_lots_paged[shop_lots_paged.len]
			part_list.len = lot_id
			part_list[lot_id] = Lot
			lot_id++
			if(lot_id > category_shop_per_page)
				lot_id = 1
				shop_lots_paged.len++
				shop_lots_paged[shop_lots_paged.len] = list()
		shop_lots_frontend = shop_lots_paged[category_shop_page]

	data["shop_lots"] = shop_lots_frontend

	data["category_shop_page"] = category_shop_page

	var/list/orders_and_offers_frontend = list()
	if(global.orders_and_offers.len)
		for(var/index in global.orders_and_offers)
			var/list/OrOf = global.orders_and_offers[index]
			orders_and_offers_frontend.len++
			orders_and_offers_frontend[orders_and_offers_frontend.len] = OrOf
	data["orders_and_offers"] = orders_and_offers_frontend

	var/list/shopping_cart_frontend = list()
	if(MA.shopping_cart.len)
		for(var/index in MA.shopping_cart)
			var/list/Item = MA.shopping_cart[index]
			shopping_cart_frontend.len++
			shopping_cart_frontend[shopping_cart_frontend.len] = Item
			shopping_cart_frontend[shopping_cart_frontend.len]["area"] = "Unknown"
			if(Item["lot_item_ref"])
				var/atom/A = locate(Item["lot_item_ref"])
				var/area/A_area = get_area(A)
				if(A && A_area)
					var/dist_str = "([get_dist(A, src)]m)"

					shopping_cart_frontend[shopping_cart_frontend.len]["area"] = "[A_area.name][dist_str]"
	data["shopping_cart"] = shopping_cart_frontend

	data["shopping_cart_amount"] = shopping_cart_frontend.len

	nanoUI = data
	// update the ui if it exists, returns null if no ui is passed/found
	if(ui)
		ui.load_cached_data(ManifestJSON)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// the ui does not exist, so we'll create a new() one
	        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "shop.tmpl", title, 640, 420)
		// when the ui is first opened this is the data it will use

		ui.load_cached_data(ManifestJSON)

		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
	// auto update every Master Controller tick
	ui.set_auto_update(1)

/obj/machinery/computer/shop/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/datum/money_account/MA = global.department_accounts[department]
	var/owner = MA.owner_name
	var/owner_account = MA.account_number

	var/mob/user = usr

	switch(href_list["choice"])
		if("Return")//Return
			mode = 1
		if("Shop_Category")
			category_shop_page = 1
			mode = 11
			var/categ = href_list["categ"]
			if(!isnull(global.shop_categories[categ]))
				category = categ
		if("Shop_Change_Page")
			var/page = href_list["shop_change_page"]
			switch(page)
				if("next")
					category_shop_page++
				if("previous")
					category_shop_page--
			category_shop_page = clamp(category_shop_page, 1, shop_lots_paged.len)
		if("Shop_Change_Per_page")
			var/number = text2num(href_list["shop_per_page"])
			if(number && (number in list(5, 10, 15, 20)))
				category_shop_per_page = number

		//Maintain Orders and Offers
		if("Shop_Add_Order_or_Offer")
			if(!global.check_cargo_consoles_operational(src))
				to_chat(user, "<span class='notice'>ОШИБКА: КПК сервер не отвечает.</span>")
				mode = 1
				return
			var/T = sanitize(input(user, "Введите описание заказа или предложения", "Комментарий", "Куплю Гараж") as text)
			if(T && istext(T) && owner && owner_account)
				global.add_order_and_offer(MA.owner_name, T)
				mode = 1
			else
				to_chat(user, "<span class='notice'>ОШИБКА: Не введено описание заказа.</span>")

		//Buy Item
		if("Shop_Order")
			if(!global.check_cargo_consoles_operational(src))
				to_chat(user, "<span class='notice'>ОШИБКА: КПК сервер не отвечает.</span>")
				mode = 1
				return
			var/id = href_list["order_item"]
			var/datum/shop_lot/Lot = global.online_shop_lots[id]
			var/orderer = " (Неизвестный)"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/weapon/card/id/ID = H.get_idcard()
				if(ID)
					orderer = " ([ID.registered_name])"
			if(Lot && owner_account)
				var/T = sanitize(input(user, "Введите адрес доставки", "Адрес доставки", null) as text)
				if(T && istext(T))
					if(Lot.sold)
						if(online_shop_lots_hashed.Find(Lot.hash))
							for(var/datum/shop_lot/NewLot in online_shop_lots_hashed[Lot.hash])
								if(NewLot && !NewLot.sold && (Lot.get_discounted_price() <= NewLot.get_discounted_price()))
									if(order_onlineshop_item(owner + orderer, owner_account, NewLot, T))
										MA.shopping_cart["[NewLot.number]"] = Lot.to_list()
									else
										to_chat(user, "<span class='notice'>ОШИБКА: Недостаточно средств.</span>")
										return
						to_chat(user, "<span class='notice'>ОШИБКА: Этот предмет уже куплен.</span>")
						return

					else if(order_onlineshop_item(owner + orderer, owner_account, Lot, T))
						MA.shopping_cart["[Lot.number]"] = Lot.to_list()
					else
						to_chat(user, "<span class='notice'>ОШИБКА: Недостаточно средств.</span>")
				else
					to_chat(user, "<span class='notice'>ОШИБКА: Не введён адрес доставки.</span>")

		//Shopping Cart
		if("Shop_Shopping_Cart")
			mode = 12
		if("Shop_Mark_As_Delivered")
			if(!global.check_cargo_consoles_operational(src))
				to_chat(user, "<span class='notice'>ОШИБКА: КПК сервер не отвечает.</span>")
				mode = 1
				return
			var/lot_id = href_list["delivered_item"]
			if(!MA.shopping_cart["[lot_id]"])
				to_chat(user, "<span class='notice'>Это не один из твоих заказов. Это заказ номер №[lot_id].</span>")
				return
			if(onlineshop_mark_as_delivered(user, lot_id, owner_account, MA.shopping_cart["[lot_id]"]["postpayment"]))
				MA.shopping_cart -= "[lot_id]"
				mode = 12

/proc/check_cargo_consoles_operational(object)
	if(!global.cargo_consoles)
		return
	for(var/obj/machinery/computer/cargo/Console in global.cargo_consoles)
		if(!Console.requestonly)
			var/turf/pos = get_turf(object)
			return is_station_level(pos.z)
