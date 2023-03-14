/datum/controller/subsystem/economy
	var/list/wanted_shop_lots

/datum/controller/subsystem/economy/proc/evaluate_demand(price, target_price)
	if(target_price == 0.0)
		return 0.0

	var/price_fraction = price / target_price
	if(price_fraction ** 2 > 1.6)
		return 0.0

	return 1.05 * sqrt(1 - 0.66 * (price_fraction ** 2))

/datum/controller/subsystem/economy/proc/monitor_cargo_shop()
	for(var/number in global.online_shop_lots)
		var/datum/shop_lot/SL = global.online_shop_lots[number]
		if(SL.sold)
			continue

		var/order_chance = evaluate_demand(SL.get_discounted_price() + SL.get_delivery_cost(), SL.market_price)
		if(!prob(order_chance * 100))
			continue

		if(order_onlineshop_item("CentComm", global.centcomm_account.account_number, SL, "Отправьте с помощью карго шаттла."))
			LAZYSET(wanted_shop_lots, "[SL.number]", SL.to_list())

/datum/controller/subsystem/economy/proc/handle_centcomm_onlineshop_orders(atom/movable/thing)
	var/lot_number = null

	if(istype(thing, /obj/structure/bigDelivery))
		var/obj/structure/bigDelivery/package = thing
		lot_number = package.lot_number
	else if(istype(thing, /obj/item/smallDelivery))
		var/obj/item/smallDelivery/package = thing
		lot_number = package.lot_number

	if(isnull(lot_number))
		return

	var/list/shop_lot = LAZYACCESS(wanted_shop_lots, "[lot_number]")
	if(!shop_lot)
		return

	var/postpayment = shop_lot["postpayment"]
	var/datum/shop_lot/Lot = global.online_shop_lots[lot_number]

	if(!Lot || !global.centcomm_account || postpayment > global.centcomm_account.money)
		return

	LAZYREMOVE(wanted_shop_lots, "[lot_number]")
	Lot.delivered = TRUE

	if(global.online_shop_discount)
		charge_to_account(Lot.account, global.cargo_account.account_number, "Возмещение скидки на [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, Lot.price - postpayment)
		charge_to_account(global.cargo_account.account_number, global.centcomm_account.account_number, "Возмещение скидки на [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, -(Lot.price - postpayment))

	charge_to_account(global.centcomm_account.account_number, global.cargo_account.account_number, "Счёт за покупку [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, -postpayment)
	charge_to_account(Lot.account, global.cargo_account.account_number, "Прибыль за продажу [Lot.name] в [CARGOSHOPNAME]", CARGOSHOPNAME, postpayment)
