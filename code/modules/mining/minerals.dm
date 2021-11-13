var/list/name_to_mineral

/proc/SetupMinerals()
	name_to_mineral = list()
	for(var/type in subtypesof(/mineral))
		var/mineral/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_mineral[new_mineral.name] = new_mineral
	return TRUE

/mineral

	var/name	      // Tag for use in overlay generation/list population	.
	var/display_name  // What am I called?
	var/result_amount // How much ore?
	var/spread = 1	  // Does this type of deposit spread?
	var/spread_chance // Chance of spreading in any direction
	var/ore	          // Path to the ore produced when tile is mined.

	var/ore_type
	var/ore_loss = 0

/mineral/New()
	. = ..()
	if(!display_name)
		display_name = name

/mineral/uranium
	name = "Uranium"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/uranium
	ore_type = "radioactive"
	ore_loss = 2

/mineral/iron
	name = "Iron"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/iron
	ore_type = "metal"
	ore_loss = 1

/mineral/diamond
	name = "Diamond"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/diamond
	ore_type = "gem"
	ore_loss = 2

/mineral/gold
	name = "Gold"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/gold
	ore_type = "metal"
	ore_loss = 4

/mineral/silver
	name = "Silver"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/silver
	ore_type = "metal"
	ore_loss = 4

/mineral/phoron
	name = "Phoron"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/phoron
	ore_type = "crystal"
	ore_loss = 3

/mineral/clown
	display_name = "Bananium"
	name = "Clown"
	result_amount = 3
	spread = 0
	ore = /obj/item/weapon/ore/clown
	ore_type = "anomaly"

/mineral/coal
	name = "Coal"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/coal
	ore_type = "coal"

/mineral/platinum
	name = "Platinum"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/osmium
