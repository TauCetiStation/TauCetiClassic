/datum/export/gatfruit
	unit_name = "strange fruit"
	cost = 150
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/gatfruit)

/*
/export/grown subtype

decreasing cost from low grown potency
use it if low potency results garbage from harvested crop
*/

/datum/export/grown/get_cost(obj/O)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
	var/ratio = G.potency / 100
	return ..() * ratio

/datum/export/grown/jupitercup
	unit_name = "strange mushroom"
	cost = 100
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/jupitercup)

/datum/export/grown/space_tobacco
	unit_name = "rare tobacco"
	cost = 75
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space)

/datum/export/grown/astra_tea
	unit_name = "rare tea"
	cost = 75
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra)

/datum/export/grown/fraxinella
	unit_name = "rare flower"
	cost = 50
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella)
