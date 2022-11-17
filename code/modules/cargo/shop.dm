var/global/list/online_shop_lots = list()
var/global/list/shop_categories = list("Еда", "Одежда", "Устройства", "Инструменты", "Ресурсы", "Наборы", "Разное")
var/global/list/cargo_consoles = list()

/datum/shop_lot
	var/name = "Лот"
	var/description = "Описание лота"
	var/price = 0
	var/number = 1
	var/category = "Разное"
	var/sold = FALSE
	var/delivered = FALSE
	var/account = 111111


/datum/shop_lot/New(name, description, price, category, number, account)
	global.online_shop_lots[number] = src
	src.name = name
	src.description = description
	src.price = price
	src.category = category
	src.number = number
	src.account = account

/datum/shop_lot/Destroy()
	global.online_shop_lots -= src
	return ..()
