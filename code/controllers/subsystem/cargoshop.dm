SUBSYSTEM_DEF(cargoshop)
	name = "Cargoshop"

	wait = 5 SECONDS
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/datum/weakref/advertisement_lot

/datum/controller/subsystem/cargoshop/fire()
	update_advertisement_lot()

/datum/controller/subsystem/cargoshop/proc/update_advertisement_lot()
	advertisement_lot = null

	if(!global.online_shop_lots_hashed?.len)
		return

	var/list/ad_items_list = list()
	for(var/hash in global.online_shop_lots_hashed) //pick a single unsold item from each hash category
		var/list/hashed_lots = global.online_shop_lots_hashed[hash]
		for(var/datum/shop_lot/lot in hashed_lots)
			if(lot.sold)
				continue

			ad_items_list += lot
			break

	if(!ad_items_list.len)
		return

	advertisement_lot = WEAKREF(pick(ad_items_list))

/datum/controller/subsystem/cargoshop/proc/get_advertisement_lot()
	return advertisement_lot?.resolve()
