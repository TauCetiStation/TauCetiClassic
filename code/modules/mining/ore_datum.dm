/datum/ore
	var/oretag
	var/start
	var/alloy
	var/smelts_to
	var/compresses_to
	var/points

/datum/ore/uranium
	start = /obj/item/weapon/ore/uranium
	smelts_to = /obj/item/stack/sheet/mineral/uranium
	oretag = "uranium"
	points = 20

/datum/ore/iron
	start = /obj/item/weapon/ore/iron
	smelts_to = /obj/item/stack/sheet/mineral/iron
	alloy = 1
	oretag = "hematite"
	points = 1

/datum/ore/coal
	start = /obj/item/weapon/ore/coal
	smelts_to = /obj/item/stack/sheet/mineral/plastic
	alloy = 1
	oretag = "coal"
	points = 1

/datum/ore/glass
	start = /obj/item/weapon/ore/glass
	smelts_to = /obj/item/stack/sheet/glass
	compresses_to = /obj/item/stack/sheet/mineral/sandstone
	alloy = 1
	oretag = "sand"
	points = 1

/datum/ore/phoron
	start = /obj/item/weapon/ore/phoron
	compresses_to = /obj/item/stack/sheet/mineral/phoron
	alloy = 1
	oretag = "phoron"
	points = 20

/datum/ore/silver
	start = /obj/item/weapon/ore/silver
	smelts_to = /obj/item/stack/sheet/mineral/silver
	oretag = "silver"
	points = 25

/datum/ore/gold
	start = /obj/item/weapon/ore/gold
	smelts_to = /obj/item/stack/sheet/mineral/gold
	oretag = "gold"
	points = 30

/datum/ore/diamond
	start = /obj/item/weapon/ore/diamond
	compresses_to = /obj/item/stack/sheet/mineral/diamond
	oretag = "diamond"
	points = 70

/datum/ore/osmium
	start = /obj/item/weapon/ore/osmium
	smelts_to = /obj/item/stack/sheet/mineral/platinum
	compresses_to = /obj/item/stack/sheet/mineral/osmium
	alloy = 1
	oretag = "platinum"
	points = 45

/datum/ore/hydrogen
	start = /obj/item/weapon/ore/hydrogen
	smelts_to = /obj/item/stack/sheet/mineral/tritium
	compresses_to = /obj/item/stack/sheet/mineral/mhydrogen
	oretag = "hydrogen"
	points = 10

/datum/ore/bananium
	start = /obj/item/weapon/ore/clown
	smelts_to = /obj/item/stack/sheet/mineral/clown
	oretag = "bananium"
	points = 7
