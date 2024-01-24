// Sell tech levels
/datum/export/tech
	cost = 100
	unit_name = "technology data disk"
	export_types = list(/obj/item/weapon/disk/tech_disk)
	var/list/techLevels = list()

/datum/export/tech/get_cost(obj/O)
	var/obj/item/weapon/disk/tech_disk/D = O
	var/cost = 0
	var/datum/tech/tech = D.stored
	cost += tech.getCost(techLevels[tech.id])
	return ..() * cost

/datum/export/tech/sell_object(obj/O)
	..()
	var/obj/item/weapon/disk/tech_disk/D = O
	if (D.stored)
		techLevels[D.stored.id] = D.stored.level
