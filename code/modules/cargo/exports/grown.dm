/datum/export/peashooter
	unit_name = "strange fruit"
	cost = 150
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter)

/datum/export/peashooter/virus
	unit_name = "strange fruit"
	cost = 250
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter)

/*
/export/grown subtype

decreasing cost from low grown potency
use it if low potency results garbage from harvested crop
*/

/datum/export/grown/get_cost(obj/O)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
	var/ratio = G.potency / 10
	return ..() * ratio

/datum/export/grown/corn
	unit_name = "corn"
	cost = 15
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)

/datum/export/grown/cherries
	unit_name = "cherries"
	cost = 50
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)

/datum/export/grown/potato
	unit_name = "potato"
	cost = 9
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)

/datum/export/grown/grapes
	unit_name = "grapes"
	cost = 17
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes)

/datum/export/grown/cabbage
	unit_name = "cabbage"
	cost = 24
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage)

/datum/export/grown/cucumber
	unit_name = "cucumber"
	cost = 13
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cucumber)

/datum/export/grown/cocoapod
	unit_name = "cocoapod"
	cost = 15
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod)

/datum/export/grown/sugarcane
	unit_name = "sugarcane"
	cost = 15
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane)

/datum/export/grown/apple
	unit_name = "apple"
	cost = 7
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)

/datum/export/grown/watermelon
	unit_name = "watermelon"
	cost = 42
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon)

/datum/export/grown/pumpkin
	unit_name = "pumpkin"
	cost = 42
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin)

/datum/export/grown/lime
	unit_name = "lime"
	cost = 10
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lime)

/datum/export/grown/lemon
	unit_name = "lemon"
	cost = 11
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lemon)

/datum/export/grown/orange
	unit_name = "orange"
	cost = 12
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/orange)

/datum/export/grown/mandarin
	unit_name = "mandarin"
	cost = 6
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mandarin)

/datum/export/grown/whitebeet
	unit_name = "whitebeet"
	cost = 7
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet)

/datum/export/grown/banana
	unit_name = "banana"
	cost = 5
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)

/datum/export/grown/chili
	unit_name = "chili"
	cost = 3
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/chili)

/datum/export/grown/eggplant
	unit_name = "eggplant"
	cost = 13
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant)

/datum/export/grown/tomato
	unit_name = "tomato"
	cost = 20
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato)

/datum/export/grown/wheat
	unit_name = "wheat"
	cost = 5
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)

/datum/export/grown/carrot
	unit_name = "carrot"
	cost = 15
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot)

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

/datum/export/seed/cucumber
	unit_name = "pack of cucumber seeds"
	cost = 15
	export_types = list(/obj/item/seeds/cucumberseed)

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
