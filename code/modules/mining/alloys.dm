//Alloys that contain subsets of each other's ingredients must be ordered in the desired sequence
//eg. steel comes after plasteel because plasteel's ingredients contain the ingredients for steel and
//it would be impossible to produce.

/datum/alloy
	var/list/requires
	var/product_mod = 1
	var/product
	var/metaltag
	var/points

/datum/alloy/plasteel
	metaltag = "plasteel"
	requires = list(
		"platinum" = 1,
		"coal" = 2,
		"hematite" = 2
		)
	product_mod = 0.3
	product = /obj/item/stack/sheet/plasteel
	points = 50

/datum/alloy/steel
	metaltag = "steel"
	requires = list(
		"coal" = 1,
		"hematite" = 1
		)
	product = /obj/item/stack/sheet/metal
	points = 5

/datum/alloy/phoron_glass
	metaltag = "phoron glass"
	requires = list(
		"phoron" = 1,
		"sand" = 1
		)
	product = /obj/item/stack/sheet/glass/phoronglass
	points = 25
