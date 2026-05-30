/datum/geode
	var/name
	var/wall_mineral
	var/wall_crystal
	var/floor_crystal
	var/items_inside
	var/gas_inside

/datum/geode/phoron
	name = "Phoron"
	wall_mineral = /mineral/phoron
	wall_crystal = /obj/structure/crystal/wall/phoron
	floor_crystal = /obj/structure/crystal/phoron
	items_inside = list(/obj/item/weapon/ore/phoron = 1)
	gas_inside = "phoron"


/obj/structure/crystal
	name = "Basalt"
	icon = 'icons/turf/rocks.dmi'
	icon_state = "basalt"
	anchored = TRUE
	density = TRUE

	max_integrity = 25
	resistance_flags = CAN_BE_HIT

	var/ore_type = /obj/item/weapon/ore/coal
	var/icon_state_variants = 3

/obj/structure/crystal/atom_init()
	. = ..()

	icon_state = "[initial(icon_state)][rand(1, icon_state_variants)]"

/obj/structure/crystal/Destroy()
	for(var/i in 1 to rand(1, 3))
		new ore_type(loc)

	..()

/obj/structure/crystal/phoron
	name = "Phoron Crystal"
	icon_state = "phoron"
	ore_type = /obj/item/weapon/ore/phoron
	icon_state_variants = 1

/obj/structure/crystal/wall/phoron
	name = "Phoron Crystal"
	icon_state = "phoron_wall"
	ore_type = /obj/item/weapon/ore/phoron
	icon_state_variants = 1
