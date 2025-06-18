var/global/list/online_shop_lots = list()
var/global/list/online_shop_lots_latest[3]
var/global/list/online_shop_lots_hashed = list()

var/global/online_shop_number = 0
var/global/list/shop_categories = list("Еда" = 0, "Одежда" = 0, "Устройства" = 0, "Инструменты" = 0, "Ресурсы" = 0, "Наборы" = 0, "Разное" = 0)

var/global/list/orders_and_offers = list()
var/global/orders_and_offers_number = 0

var/global/online_shop_discount = 0
var/global/online_shop_delivery_cost = 0.15
var/global/online_shop_profits = 0

/datum/shop_lot
	var/name = "Лот"
	var/description = "Описание лота"
	var/price = 0
	var/number = 1
	var/category = "Разное"
	var/sold = FALSE
	var/delivered = FALSE
	var/account = 111111
	var/item_icon = ""
	var/hash = ""
	var/lot_item_ref = ""
	// How much would exporting this item via cargo shuttle pay up.
	var/market_price = 0

/datum/shop_lot/New(name, description, price, category, account, icon, lot_item_ref, market_price)
	global.online_shop_number++
	global.online_shop_lots["[global.online_shop_number]"] = src

	src.name = name
	src.description = description
	src.price = price
	src.category = category
	src.number = "[global.online_shop_number]"
	src.account = account
	src.item_icon = icon
	src.lot_item_ref = lot_item_ref
	src.market_price = market_price

	src.hash = "[src.category]-[src.name]-[src.description]-[src.price]-[src.account]"

	LAZYADDASSOCLIST(global.online_shop_lots_hashed, src.hash, src)

	global.online_shop_lots_latest.Swap(2, 3)
	global.online_shop_lots_latest.Swap(1, 2)
	global.online_shop_lots_latest[1] = src

/datum/shop_lot/Destroy()
	global.online_shop_lots -= "[number]"
	for(var/i=1, i<=3, i++)
		if(global.online_shop_lots_latest[i] == src)
			global.online_shop_lots_latest[i] = null
			break

	LAZYREMOVEASSOC(global.online_shop_lots_hashed, src.hash, src)
	return ..()

/datum/shop_lot/proc/to_list()
	var/datum/money_account/MA = get_account(account)

	var/price_str = "[get_discounted_price() + get_delivery_cost()]"
	if(global.online_shop_discount)
		price_str = "<S>[src.price + get_delivery_cost()]</S> <B>[get_discounted_price() + get_delivery_cost()]</B>"

	return list(
		"name" = name,
		"description" = src.description,
		"price" = price_str,
		"number" = number,
		"seller" = MA ? MA.owner_name : "Unknown",
		"account" = account,
		"delivered" = delivered,
		"postpayment" = get_discounted_price(),
		"icon" = item_icon,
		"lot_item_ref" = lot_item_ref,
	)

/datum/shop_lot/proc/get_delivery_cost()
	return round(price * global.online_shop_delivery_cost, 0.1)

/datum/shop_lot/proc/get_discounted_price()
	return round((1 - global.online_shop_discount) * price, 0.1)

/datum/shop_lot/proc/mark_delivered()
	delivered = TRUE

	var/atom/A = locate(lot_item_ref)
	if(!A)
		return

	for(var/obj/thing in A)
		thing.remove_price_tag()

	if(istype(A, /obj/item/smallDelivery))
		var/obj/item/smallDelivery/package = A
		package.cut_overlay(package.lot_lock_image)
		package.lot_lock_image = null
		if(istype(package.loc, /obj/lot_holder))
			var/obj/lot_holder/Holder = package.loc
			qdel(Holder)
		return

	if(istype(A, /obj/structure/bigDelivery))
		var/obj/structure/bigDelivery/package = A
		package.cut_overlay(package.lot_lock_image)
		package.lot_lock_image = null
		return

/proc/order_onlineshop_item(orderer_name, account, datum/shop_lot/Lot, destination)
	if(!Lot)
		return FALSE

	var/datum/money_account/MA = get_account(account)
	if(!MA)
		return FALSE

	var/delivery_cost = Lot.get_delivery_cost()
	if(delivery_cost > MA.money)
		return FALSE

	Lot.sold = TRUE

	for(var/i in 1 to 3)
		if(global.online_shop_lots_latest[i] == Lot)
			global.online_shop_lots_latest[i] = null
			break

	global.shop_categories[Lot.category]--

	charge_to_account(MA.account_number, global.cargo_account.account_number, "Предоплата за покупку [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, -delivery_cost)
	charge_to_account(global.cargo_account.account_number, MA.account_number, "Предоплата за покупку [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, delivery_cost)

	for(var/obj/machinery/computer/cargo/Console in global.cargo_consoles)
		if(istype(Console, /obj/machinery/computer/cargo/request))
			continue

		var/static/list/category2color = list(
			"Еда" = "orange",
			"Одежда" = "green",
			"Устройства" = "purple",
			"Инструменты" = "red",
			"Ресурсы" = "blue",
			"Наборы" = "yellow",
			// "Разное" = no colour,
		)

		var/color_string = ""
		if(category2color[Lot.category])
			color_string = " ([category2color[Lot.category]])"

		var/obj/item/weapon/paper/P = new(get_turf(Console.loc))

		P.name = "Заказ предмета №[Lot.number] из магазина"
		P.info += "Посылка номер №[Lot.number]<br>"
		P.info += "Наименование: [Lot.name]<br>"
		P.info += "Цена: [Lot.price]$<br>"
		P.info += "Категория: [Lot.category][color_string]<br>"
		P.info += "Время заказа: [worldtime2text()]<br>"
		P.info += "Заказал: [orderer_name ? orderer_name : "Unknown"]<br>"
		P.info += "Подпись заказчика: <span class=\"sign_field\"></span><br>"
		P.info += "Комментарий: [destination]<br>"
		P.info += "<hr>"
		P.info += "МЕСТО ДЛЯ ШТАМПОВ:<br>"

		var/obj/item/weapon/pen/Pen = new

		P.parsepencode(P.info, Pen)
		P.updateinfolinks()
		qdel(Pen)

		P.update_icon()
	return TRUE

/proc/onlineshop_mark_as_delivered(mob/user, id, account_number, postpayment)
	id = "[id]"

	var/datum/shop_lot/Lot = global.online_shop_lots[id]
	if(!Lot)
		if(user)
			to_chat(user, "<span class='warning'>Этот лот больше не существует.</span>")
		return FALSE

	var/datum/money_account/MA = get_account(account_number)
	if(!MA)
		if(user)
			to_chat(user, "<span class='notice'>ОШИБКА: Никакой счёт не подвязан к данному КПК.</span>")
		return FALSE

	if(postpayment > MA.money)
		if(user)
			to_chat(user, "<span class='notice'>ОШИБКА: Недостаточно средств.</span>")
		return FALSE

	Lot.mark_delivered()

	if(global.online_shop_discount)
		charge_to_account(Lot.account, global.cargo_account.account_number, "Возмещение скидки на [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, Lot.price - postpayment)
		charge_to_account(global.cargo_account.account_number, MA.account_number, "Возмещение скидки на [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, -(Lot.price - postpayment))

	charge_to_account(MA.account_number, global.cargo_account.account_number, "Счёт за покупку [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, -postpayment)
	charge_to_account(Lot.account, global.cargo_account.account_number, "Прибыль за продажу [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, postpayment)
	return TRUE

/proc/add_order_and_offer(Name, Text)
	global.orders_and_offers["[global.orders_and_offers_number]"] = list("name" = Name, "description" = Text, "time" = worldtime2text())
	global.orders_and_offers_number++
