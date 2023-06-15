var/global/list/labor_rates = list()

/datum/labor
	var/product
	var/nametag
	var/price

/*************** Materials **********************/
/datum/labor/metal
	product = /obj/item/stack/sheet/metal
	nametag = "metal"
	price = 0.5

/datum/labor/glass
	product = /obj/item/stack/sheet/glass
	nametag = "glass"
	price = 0.5

/datum/labor/plasteel
	product = /obj/item/stack/sheet/plasteel
	nametag = "plasteel"
	price = 8

/datum/labor/rglass
	product = /obj/item/stack/sheet/rglass
	nametag = "reinforced glass"
	price = 0.7

/datum/labor/wood
	product = /obj/item/stack/sheet/wood
	nametag = "wood plank"
	price = 7

/datum/labor/cardboard
	product = /obj/item/stack/sheet/cardboard
	nametag = "cardboard"
	price = 0.1

/datum/labor/bananium
	product = /obj/item/stack/sheet/mineral/clown
	nametag = "bananium"
	price = 500

/datum/labor/diamond
	product = /obj/item/stack/sheet/mineral/diamond
	nametag = "diamond"
	price = 250

/datum/labor/phoron
	product = /obj/item/stack/sheet/mineral/phoron
	nametag = "phoron"
	price = 35

/datum/labor/scrap
	product = /obj/item/stack/sheet/refined_scrap
	nametag = "scrap"
	price = 17

/datum/labor/uranium
	product = /obj/item/stack/sheet/mineral/uranium
	nametag = "uranium"
	price = 40

/datum/labor/gold
	product = /obj/item/stack/sheet/mineral/gold
	nametag = "gold"
	price = 25

/datum/labor/silver
	product = /obj/item/stack/sheet/mineral/silver
	nametag = "silver"
	price = 10

/datum/labor/plastic
	product = /obj/item/stack/sheet/mineral/plastic
	nametag = "plastic"
	price = 2

/datum/labor/platinum
	product = /obj/item/stack/sheet/mineral/platinum
	nametag = "platinum"
	price = 100

/*************** Misc **********************/

/datum/labor/grown
	product = /obj/item/weapon/reagent_containers/food/snacks/grown
	nametag = "grown food"
	price = 0.5
