var/global/list/online_shop_lots = list()
var/global/list/online_shop_lots_latest[3]
var/global/list/online_shop_lots_hashed = list()

var/global/online_shop_number = 0
var/global/list/shop_categories = list("Еда" = 0, "Одежда" = 0, "Устройства" = 0, "Инструменты" = 0, "Ресурсы" = 0, "Наборы" = 0, "Разное" = 0)
var/global/list/shop_category2color = list(
		"Еда" = "orange",
		"Одежда" = "green",
		"Устройства" = "purple",
		"Инструменты" = "red",
		"Ресурсы" = "blue",
		"Наборы" = "yellow",
		// "Разное" = no colour,
	)

var/global/list/orders_and_offers = list()
var/global/orders_and_offers_number = 0

var/global/online_shop_discount = 0
var/global/online_shop_delivery_cost = 0.15
var/global/online_shop_profits = 0
var/global/online_shop_ads = TRUE
var/global/online_shop_referrer_revenue = 0.50

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
	// Referrer that makes revenue from advertisements.
	var/referrer_account = null
	var/referrer_revenue = 0

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

/datum/shop_lot/proc/get_seller()
	var/datum/money_account/MA = get_account(account)

	return MA ? MA.owner_name : "Unknown"

/datum/shop_lot/proc/get_price_string()
	var/price_str = "[get_discounted_price() + get_delivery_cost()]"
	if(global.online_shop_discount)
		price_str = "<S>[src.price + get_delivery_cost()]</S> <B>[get_discounted_price() + get_delivery_cost()]</B>"

	return price_str

/datum/shop_lot/proc/to_list()
	return list(
		"name" = name,
		"description" = src.description,
		"price" = get_price_string(),
		"number" = number,
		"seller" = get_seller(),
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

/datum/shop_lot/proc/get_referrer_revenue()
	return round(get_delivery_cost() * global.online_shop_referrer_revenue, 0.1)

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

/proc/create_onlineshop_item(obj/Item, lot_name, lot_desc, lot_price, lot_category, lot_account, item_icon)
	var/market_price = export_item_and_contents(Item, FALSE, FALSE, dry_run=TRUE)
	var/datum/shop_lot/Lot = new /datum/shop_lot(lot_name, lot_desc, lot_price, lot_category, lot_account, item_icon, "[REF(Item)]", market_price)

	global.shop_categories[lot_category]++

	Item.name = "Посылка номер: [global.online_shop_number]"
	Item.desc = "Наименование: [lot_name], Описание: [lot_desc], Цена: [lot_price]"

	if(istype(Item, /obj/structure/bigDelivery))
		var/obj/structure/bigDelivery/Package = Item
		Package.lot_number = Lot.number
	else
		var/obj/item/smallDelivery/Package = Item
		Package.lot_number = Lot.number

	return Lot

/proc/order_onlineshop_item(orderer_name, account, datum/shop_lot/Lot, destination, referrer_account = null)
	if(!Lot)
		return FALSE

	if(referrer_account)
		Lot.referrer_account = referrer_account
		Lot.referrer_revenue = Lot.get_referrer_revenue()

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

	charge_to_account(MA.account_number, global.cargo_account.account_number, "Предоплата за покупку [Lot.name] в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, -delivery_cost)
	charge_to_account(global.cargo_account.account_number, MA.account_number, "Предоплата за покупку [Lot.name] в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, delivery_cost)

	for(var/obj/machinery/computer/cargo/Console in global.cargo_consoles)
		if(istype(Console, /obj/machinery/computer/cargo/request))
			continue

		var/color_string = ""
		if(global.shop_category2color[Lot.category])
			color_string = " ([global.shop_category2color[Lot.category]])"

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
		charge_to_account(Lot.account, global.cargo_account.account_number, "Возмещение скидки на [Lot.name] в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, Lot.price - postpayment)
		charge_to_account(global.cargo_account.account_number, MA.account_number, "Возмещение скидки на [Lot.name] в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, -(Lot.price - postpayment))

	charge_to_account(MA.account_number, global.cargo_account.account_number, "Счёт за покупку [Lot.name] в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, -postpayment)
	charge_to_account(Lot.account, global.cargo_account.account_number, "Прибыль за продажу [Lot.name] в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, postpayment)

	if(Lot.referrer_account)
		var/datum/money_account/referrer_acc = get_account(Lot.referrer_account)
		if(referrer_acc)
			charge_to_account(referrer_acc.account_number, global.cargo_account.account_number, "Выплата за покупку по реферальной ссылке в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, Lot.referrer_revenue)
			charge_to_account(global.cargo_account.account_number, referrer_acc.account_number, "Выплата за покупку по реферальной ссылке в магазине '[CARGOSHOPNAME]'", CARGOSHOPNAME, -Lot.referrer_revenue)

	return TRUE

/proc/add_order_and_offer(Name, Text)
	global.orders_and_offers["[global.orders_and_offers_number]"] = list("name" = Name, "description" = Text, "time" = worldtime2text())
	global.orders_and_offers_number++



/proc/get_item_shop_category(obj/target)
	if(istype(target, /obj/item/weapon/reagent_containers/food))
		return "Еда"
	else if(istype(target, /obj/item/weapon/storage/food))
		return "Еда"
	else if(istype(target, /obj/item/weapon/storage))
		return "Наборы"
	else if(istype(target, /obj/item/weapon))
		return "Инструменты"
	else if(istype(target, /obj/item/clothing))
		return "Одежда"
	else if(istype(target, /obj/item/device))
		return "Устройства"
	else if(istype(target, /obj/item/stack))
		return "Ресурсы"
	else
		return "Разное"

/proc/shop_object2package(obj/Item)
	var/itemPixelX = Item.pixel_x
	var/itemPixelY = Item.pixel_y

	var/obj/Package = Item.try_wrap_up()
	if(!Package)
		return

	if(istype(Package, /obj/item/smallDelivery))
		var/obj/item/smallDelivery/P = Package
		P.lot_lock_image = image('icons/obj/package_wrap.dmi', "[P.icon_state]-shop")
		P.lot_lock_image.appearance_flags = RESET_COLOR
		P.add_overlay(P.lot_lock_image)
	else
		var/obj/structure/bigDelivery/P = Package
		P.lot_lock_image = image('icons/obj/package_wrap.dmi', "[P.icon_state]-shop")
		P.lot_lock_image.appearance_flags = RESET_COLOR
		P.add_overlay(P.lot_lock_image)

	Package.modify_max_integrity(75)
	Package.atom_fix()
	Package.damage_deflection = 25

	Item = Package

	Item.pixel_x = itemPixelX
	Item.pixel_y = itemPixelY

	return Item

/proc/object2onlineshop_package(obj/Item, forceColor = null, hideIcon = FALSE)
	var/lot_name = Item.name
	var/lot_desc = Item.price_tag["description"]
	var/lot_price = Item.price_tag["price"]
	var/lot_category = Item.price_tag["category"]
	var/lot_account = Item.price_tag["account"]
	var/item_icon
	if(!hideIcon)
		item_icon = bicon(Item)

	Item = shop_object2package(Item)

	if(forceColor)
		Item.color = forceColor
	else if(global.shop_category2color[lot_category])
		Item.color = global.shop_category2color[lot_category]

	if(hideIcon)
		item_icon = bicon(Item)

	create_onlineshop_item(Item, lot_name, lot_desc, lot_price, lot_category, lot_account, item_icon)

	return Item

var/global/list/random_onlineshop_items = list()
ADD_TO_GLOBAL_LIST(/obj/random_shop_item, random_onlineshop_items)
/obj/random_shop_item
	name = "Random OnlineShop item"
	desc = "Случайный товар для грузторга."
	icon = 'icons/obj/package_wrap.dmi'
	icon_state = "deliverycrateSmall"
	flags = ABSTRACT

/obj/random_shop_item/proc/generate_shop_item()
	var/item_path = PATH_OR_RANDOM_PATH(/obj/random/trader_product_safer)

	if(!item_path)
		qdel(src)
		return

	var/obj/item/Item = new item_path(loc)

	var/market_price = export_item_and_contents(Item, FALSE, FALSE, dry_run=TRUE)
	var/new_price = market_price ? round(market_price * pick(1.1, 1.2, 1.3)) : 50

	Item.add_price_tag(Item.desc, new_price, get_item_shop_category(Item), global.cargo_account.account_number)

	Item = object2onlineshop_package(Item)

	Item.pixel_x = rand(-10, 10)
	Item.pixel_y = rand(-10, 10)

	qdel(src)

/proc/get_random_unique_onlineshop_lot()
	if(!global.online_shop_lots_hashed?.len)
		return null

	var/random_lot_hash = pick(global.online_shop_lots_hashed)

	var/list/hashed_lots = global.online_shop_lots_hashed[random_lot_hash]
	if(!hashed_lots.len)
		return null

	return pick(hashed_lots)

/proc/get_onlineshop_advertisement(atom/source, referrer_account = null, no_link = FALSE)
	var/datum/shop_lot/lot = get_random_unique_onlineshop_lot()
	if(!lot)
		return

	var/data = "<div class='Section'><center><table class='shop' style='width: 100%;'><tbody>"
	data += "<tr><th colspan='4' class='cargo'>Успейте купить [lot.name] <B>в магазине '[CARGOSHOPNAME]'!</B></th></tr>"
	data += "<tr><td rowspan='2'>[lot.item_icon]<br></td>"
	data += "<td colspan='2'><B>Цена: </B><span class='good'><SMALL><I>[lot.get_price_string()]$</I></SMALL></span></td>"

	if(no_link)
		data += "<td>'[CARGOSHOPNAME]' в КПК</td>"
	else
		data += "<td><a href='byond://?src=\ref[source];pda_onlineshop=1;referrer_account=[referrer_account]' style='float:right;'>'[CARGOSHOPNAME]' в КПК</a></td>"

	data += "<tr><td colspan='3'><SMALL><I>[lot.description]</I></SMALL><br></td></tr>"
	data += "</tbody></table></center></div><br>"

	return data


/proc/check_active_cargonauts()
	var/manifest = global.data_core.get_manifest()
	for(var/civ in manifest["civ"])
		if(civ["active"] == "Active" && (civ["rank"] in list("Quartermaster", "Cargo Technician")))
			return TRUE

	return FALSE
