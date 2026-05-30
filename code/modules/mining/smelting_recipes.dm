/datum/smelting_recipe
	var/temp
	var/input
	var/list/inputgasses
	var/output
	var/list/outputgasses


/datum/smelting_recipe/iron
	temp = T0C + 1538
	input = "hematite"
	output = /obj/item/stack/sheet/mineral/iron

/datum/smelting_recipe/steelmethane
	temp = T0C + 1370
	input = "hematite"
	inputgasses = list("methane")
	output = /obj/item/stack/sheet/metal

/datum/smelting_recipe/steelphoron
	temp = T0C + 1370
	input = "hematite"
	inputgasses = list("phoron")
	output = /obj/item/stack/sheet/metal

/datum/smelting_recipe/uranium
	temp = T0C + 2000
	input = "uranium"
	inputgasses = list("hydrogen")
	output = /obj/item/stack/sheet/mineral/uranium

/datum/smelting_recipe/glass
	temp = T0C + 2200
	input = "sand"
	output = /obj/item/stack/sheet/glass

/datum/smelting_recipe/phoronglass
	temp = T0C + 2000
	input = "sand"
	inputgasses = list("phoron")
	output = /obj/item/stack/sheet/glass/phoronglass

/datum/smelting_recipe/methane
	temp = T0C + 700
	input = "coal"
	outputgasses = list("methane")

/datum/smelting_recipe/plastic
	temp = T0C + 500
	input = "coal"
	inputgasses = list("methane")
	output = /obj/item/stack/sheet/mineral/plastic

/datum/smelting_recipe/phoron
	temp = T0C + 3000
	input = "phoron"
	outputgasses = list("phoron")

/datum/smelting_recipe/silver
	temp = T0C + 961
	input = "silver"
	output = /obj/item/stack/sheet/mineral/silver

/datum/smelting_recipe/gold
	temp = T0C + 1064
	input = "gold"
	output = /obj/item/stack/sheet/mineral/gold

/datum/smelting_recipe/osmium
	temp = T0C + 3030
	input = "platinum"
	output = /obj/item/stack/sheet/mineral/platinum

/datum/smelting_recipe/hydrogentritium
	temp = T0C + 500
	input = "hydrogen"
	inputgasses = list("phoron")
	output = /obj/item/stack/sheet/mineral/tritium

/datum/smelting_recipe/hydrogengas
	temp = T0C + 1000
	input = "hydrogen"
	outputgasses = list("hydrogen")

/datum/smelting_recipe/slag
	temp = T0C + 500
	input = "slag"
	outputgasses = list("carbon_dioxide")
