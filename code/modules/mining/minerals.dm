var/global/list/name_to_mineral

/proc/SetupMinerals()
	name_to_mineral = list()
	for(var/type in subtypesof(/mineral))
		var/mineral/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_mineral[new_mineral.name] = new_mineral
	return 1

/mineral
	var/name             // Tag for use in overlay generation/list population
	var/display_name     // What am I called?
	var/spread = TRUE    // Does this type of deposit spread?
	var/spread_chance    // Chance of spreading in any direction
	var/ore              // Path to the ore produced when tile is mined
	var/ore_type

/mineral/New()
	. = ..()
	if(!display_name)
		display_name = name

/mineral/uranium
	name = "Uranium"
	spread_chance = 10
	ore = /obj/item/weapon/ore/uranium
	ore_type = "radioactive"

/mineral/iron
	name = "Iron"
	spread_chance = 25
	ore = /obj/item/weapon/ore/iron
	ore_type = "metal"

/mineral/diamond
	name = "Diamond"
	spread_chance = 10
	ore = /obj/item/weapon/ore/diamond
	ore_type = "gem"

/mineral/gold
	name = "Gold"
	spread_chance = 10
	ore = /obj/item/weapon/ore/gold
	ore_type = "metal"

/mineral/silver
	name = "Silver"
	spread_chance = 10
	ore = /obj/item/weapon/ore/silver
	ore_type = "metal"

/mineral/phoron
	name = "Phoron"
	spread_chance = 25
	ore = /obj/item/weapon/ore/phoron
	ore_type = "crystal"

/mineral/clown
	display_name = "Bananium"
	name = "Clown"
	spread = 0
	ore = /obj/item/weapon/ore/clown
	ore_type = "anomaly"

/mineral/coal
	name = "Coal"
	spread_chance = 25
	ore = /obj/item/weapon/ore/coal
	ore_type = "coal"

/mineral/platinum
	name = "Platinum"
	spread_chance = 10
	ore = /obj/item/weapon/ore/osmium
