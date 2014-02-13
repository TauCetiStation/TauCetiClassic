var/list/name_to_mineral

proc/SetupMinerals()
	name_to_mineral = list()
	for(var/type in typesof(/mineral) - /mineral)
		var/mineral/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_mineral[new_mineral.name] = new_mineral
	return 1

mineral
	///What am I called?
	var/name
	var/display_name
	///How much ore?
	var/result_amount
	///Does this type of deposit spread?
	var/spread = 1
	///Chance of spreading in any direction
	var/spread_chance

	///Path to the resultant ore.
	var/ore

	var/ore_type
	var/ore_loss = 0
	New()
		. = ..()
		if(!display_name)
			display_name = name

mineral/uranium
	name = "Uranium"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/uranium
	ore_type = "radioactive"
	ore_loss = 2

mineral/iron
	name = "Iron"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/iron
	ore_type = "metal"
	ore_loss = 1

mineral/diamond
	name = "Diamond"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/diamond
	ore_type = "gem"
	ore_loss = 2

mineral/gold
	name = "Gold"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/gold
	ore_type = "metal"
	ore_loss = 4

mineral/silver
	name = "Silver"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/silver
	ore_type = "metal"
	ore_loss = 4

mineral/plasma
	name = "Plasma"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/plasma
	ore_type = "crystal"
	ore_loss = 3

mineral/clown
	display_name = "Bananium"
	name = "Clown"
	result_amount = 3
	spread = 0
	ore = /obj/item/weapon/ore/clown
	ore_type = "anomaly"