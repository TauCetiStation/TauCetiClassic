/datum/export/peashooter
	unit_name = "strange fruit"
	cost = 150
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter)

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

/datum/export/seed/get_cost(obj/O)
	var/obj/item/seeds/S = O
	var/ratio = S.potency / 100
	return ..() * ratio

/datum/export/seed/nettle
	unit_name = "pack of nettle seeds"
	cost = 5
	export_types = list(/obj/item/seeds/nettleseed)

/datum/export/seed/plumpmycelium
	unit_name = "pack of plump-helmet mycelium"
	cost = 10
	export_types = list(/obj/item/seeds/plumpmycelium)

/datum/export/seed/plumpmycelium
	unit_name = "pack of fly amanita mycelium"
	cost = 10
	export_types = list(/obj/item/seeds/amanitamycelium)

/datum/export/seed/libertymycelium
	unit_name = "pack of liberty-cap mycelium"
	cost = 10
	export_types = list(/obj/item/seeds/libertymycelium)

/datum/export/seed/reishimycelium
	unit_name = "pack of reishi mycelium"
	cost = 10
	export_types = list(/obj/item/seeds/reishimycelium)

/datum/export/seed/banana
	unit_name = "pack of banana seeds"
	cost = 15
	export_types = list(/obj/item/seeds/bananaseed)

/datum/export/seed/rice
	unit_name = "pack of rice seeds"
	cost = 15
	export_types = list(/obj/item/seeds/riceseed)

/datum/export/seed/eggplant
	unit_name = "pack of eggplant seeds"
	cost = 15
	export_types = list(/obj/item/seeds/eggplantseed)

/datum/export/seed/lime
	unit_name = "pack of lime seeds"
	cost = 15
	export_types = list(/obj/item/seeds/limeseed)

/datum/export/seed/grape
	unit_name = "pack of grape seeds"
	cost = 15
	export_types = list(/obj/item/seeds/grapeseed)

/datum/export/seed/egg
	unit_name = "pack of egg seeds"
	cost = 20
	export_types = list(/obj/item/seeds/eggyseed)

/datum/export/seed/replicapod
	unit_name = "pack of dionaea-replicant seeds"
	cost = 50
	export_types = list(/obj/item/seeds/replicapod)
