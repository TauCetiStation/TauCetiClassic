/datum/export/factory
	cost = 0
	include_subtypes = TRUE
	unit_name = "manufacturing parts"
	export_types = list(/obj/item/manufacturing_parts)

/datum/export/factory/get_type_cost(export_type, amount = 1, contr = 0, emag = 0)
	var/production_cost = 0

	var/list/items = list()
	var/obj/item/manufacturing_parts/export_item = new export_type()
	items |= export_item.product_type
	qdel(export_item)

	for(var/product_type in items)
		for(var/datum/export/E in global.exports_list)
			if(E.applies_to_type(product_type))
				production_cost += E.get_type_cost(product_type, 1)

	production_cost /= items.len
	production_cost *= (1 - CARGO_FACTORY_MARGIN)

	return round(production_cost)
