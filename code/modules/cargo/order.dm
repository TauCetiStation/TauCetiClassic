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
	P.info += "Comment: [reason]<br>"
	P.info += "<hr>"
	P.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	P.update_icon()
	return P

/datum/supply_order/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = object.generate(T)
	return C
