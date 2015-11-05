/datum/ore
	var/oretag
	var/start
	var/alloy
	var/smelts_to
	var/compresses_to

/datum/ore/uranium
	start = /obj/item/weapon/ore/uranium
	smelts_to = /obj/item/stack/sheet/mineral/uranium
	oretag = "uranium"

/datum/ore/iron
	start = /obj/item/weapon/ore/iron
	smelts_to = /obj/item/stack/sheet/mineral/iron
	alloy = 1
	oretag = "hematite"

/datum/ore/coal
	start = /obj/item/weapon/ore/coal
	smelts_to = /obj/item/stack/sheet/mineral/plastic
	alloy = 1
	oretag = "coal"

/datum/ore/glass
	start = /obj/item/weapon/ore/glass
	smelts_to = /obj/item/stack/sheet/glass
	compresses_to = /obj/item/stack/sheet/mineral/sandstone
	oretag = "sand"

/datum/ore/phoron
	start = /obj/item/weapon/ore/phoron
	compresses_to = /obj/item/stack/sheet/mineral/phoron
	oretag = "phoron"

/datum/ore/silver
	start = /obj/item/weapon/ore/silver
	smelts_to = /obj/item/stack/sheet/mineral/silver
	oretag = "silver"

/datum/ore/gold
	start = /obj/item/weapon/ore/gold
	smelts_to = /obj/item/stack/sheet/mineral/gold
	oretag = "gold"

/datum/ore/diamond
	start = /obj/item/weapon/ore/diamond
	compresses_to = /obj/item/stack/sheet/mineral/diamond
	oretag = "diamond"

/datum/ore/osmium
	start = /obj/item/weapon/ore/osmium
	smelts_to = /obj/item/stack/sheet/mineral/platinum
	compresses_to = /obj/item/stack/sheet/mineral/osmium
	alloy = 1
	oretag = "platinum"

/datum/ore/hydrogen
	start = /obj/item/weapon/ore/hydrogen
	smelts_to = /obj/item/stack/sheet/mineral/tritium
	compresses_to = /obj/item/stack/sheet/mineral/mhydrogen
	oretag = "hydrogen"