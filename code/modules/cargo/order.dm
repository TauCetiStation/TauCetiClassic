/obj/item/weapon/paper/manifest
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0

/obj/item/weapon/paper/manifest/atom_init(mapload, id, cost)
	. = ..()
	order_id = id
	order_cost = cost

	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_NAME
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_CONTENTS
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_ITEM

/obj/item/weapon/paper/manifest/proc/is_approved()
	return stamped && stamped.len && !is_denied()

/obj/item/weapon/paper/manifest/proc/is_denied()
	return stamped && (/obj/item/weapon/stamp/denied in stamped)

/datum/supply_order
	var/id
	var/orderer = null
	var/orderer_rank = null
	var/orderer_ckey = null
	var/reason = null
	var/datum/supply_pack/object

/datum/supply_order/New(datum/supply_pack/object, orderer, orderer_rank, orderer_ckey, reason)
	id = SSshuttle.ordernum++
	src.object = object
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/weapon/paper/P = new(T)

	P.name = "Requisition Form - #[id] ([object.name])"
	P.info += "<h3>[station_name()] Supply Requisition Form</h3><hr>"
	P.info += "Order #[id]<br>"
	P.info += "Item: [object.name]<br>"
	P.info += "Access Restrictions: [get_access_desc(object.access)]<br>"
	P.info += "Requested by: [orderer]<br>"
	P.info += "Rank: [orderer_rank]<br>"
	P.info += "Contents:<br>"
	P.info += object.true_manifest
	P.info += "Comment: [reason]<br>"
	P.info += "<hr>"
	P.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	P.update_icon()
	return P

/datum/supply_order/proc/generateManifest(obj/structure/closet/crate/C)
	var/obj/item/weapon/paper/manifest/P = new(C, id, object.cost)

	var/station_name = (P.errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()

	P.name = "shipping manifest - #[id] ([object.name])"
	P.info += "<h2>[command_name()] Shipping Manifest</h2>"
	P.info += "<hr/>"
	P.info += "Order #[id]<br/>"
	P.info += "Destination: [station_name]<br/>"
	P.info += "Item: [object.name]<br/>"
	P.info += "Contents: <br/>"
	P.info += "<ul>"
	for(var/atom/movable/AM in C.contents - P)
		if((P.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				P.info += "<li>[AM.name]</li>"
			else
				continue
		P.info += "<li>[AM.name]</li>"
	P.info += "</ul>"
	P.info += "<h4>Stamp below to confirm receipt of goods:</h4>"

	P.update_icon()
	P.loc = C
	//C.manifest = P
	//C.update_icon()

	return P

/datum/supply_order/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = object.generate(T)
	var/obj/item/weapon/paper/manifest/M = generateManifest(C)

	if(M.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			M.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))
	return C
