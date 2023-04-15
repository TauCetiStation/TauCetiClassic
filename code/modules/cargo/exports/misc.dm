//All other

/* /datum/export/misc/ashtray
	cost = 5
	unit_name = "ashtray"
	export_types = list(/obj/item/ashtray)

/datum/export/misc/candle
	cost = 15
	unit_name = "candle"
	export_types = list(/obj/item/candle)

/datum/export/misc/headset
	cost = 40
	unit_name = "headset"
	export_types = list(/obj/item/device/radio/headset) */

/datum/export/misc/grownfood
	cost = 5
	unit_name = "grown food"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown)

/datum/export/misc/wooden_box
	cost = 50
	unit_name = "wooden box"
	export_types = list(/obj/item/weapon/wooden_box)

/datum/export/misc/wooden_box/get_cost(obj/item/weapon/wooden_box/Box)
	var/return_cost = 0
	for(var/obj/item/I in Box.contents)
		return_cost += export_item_and_contents(I, FALSE, FALSE, dry_run=TRUE)

	return ..() + return_cost
