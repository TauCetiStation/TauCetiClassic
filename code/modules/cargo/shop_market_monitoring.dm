/datum/controller/subsystem/economy
	var/list/wanted_shop_lots

/datum/controller/subsystem/economy/proc/evaluate_demand(price, target_price)
	if(target_price == 0.0)
		return 0.0

	var/price_fraction = price / target_price
	if(price_fraction ** 2 > 1.5)
		return 0.0

	return 1.05 * sqrt(1 - 0.66 * (price_fraction ** 2))

/datum/controller/subsystem/economy/proc/monitor_cargo_shop()
	for(var/number in global.online_shop_lots)
		var/datum/shop_lot/SL = global.online_shop_lots[number]
		if(SL.sold)
			continue

		var/price = SL.get_discounted_price() + SL.get_delivery_cost()
		// Delivery fees are not taxed, only export is.
		var/tax = round(SL.get_discounted_price() * SSeconomy.tax_cargo_export * 0.01)

		var/order_chance = evaluate_demand(price + tax, SL.market_price)
		if(!prob(order_chance * 100))
			continue

		if(order_onlineshop_item("CentComm", global.centcomm_account.account_number, SL, "Отправьте с помощью карго шаттла."))
			var/list/L = SL.to_list()
			L["tax"] = SSeconomy.tax_cargo_export
			LAZYSET(wanted_shop_lots, "[SL.number]", L)

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

	if(!onlineshop_mark_as_delivered(null, lot_number, global.centcomm_account.account_number, shop_lot["postpayment"]))
		return

	// Paying taxes on the item.
	var/tax = round(shop_lot["postpayment"] * shop_lot["tax"] * 0.01)

	charge_to_account(global.centcomm_account.account_number, global.station_account.account_number, "Налог на экспорт [shop_lot["name"]] из [CARGOSHOPNAME]", "НТС Велосити", -tax)
	charge_to_account(global.station_account.account_number, global.station_account.owner_name, "Налог на экспорт", "НТС Велосити", tax)
