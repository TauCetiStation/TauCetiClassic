//TOOLS RANDOM
/obj/random/materials
	name = "Random Material"
	desc = "This is a random tool."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-metal"

/obj/random/materials/rods_scrap/atom_init()
	..()
	new /obj/item/stack/rods/(loc, rand(3,8))
	return INITIALIZE_HINT_QDEL

/obj/random/materials/plastic_scrap/atom_init()
	..()
	new /obj/item/stack/sheet/mineral/plastic(loc, rand(5,10))
	return INITIALIZE_HINT_QDEL

/obj/random/materials/metal_scrap/atom_init()
	..()
	new /obj/item/stack/sheet/metal(loc, rand(8,12))
	return INITIALIZE_HINT_QDEL

/obj/random/materials/glass_scrap/atom_init()
	..()
	new /obj/item/stack/sheet/glass(loc, rand(5,10))
	return INITIALIZE_HINT_QDEL

/obj/random/materials/plasteel_scrap/atom_init()
	..()
	new /obj/item/stack/sheet/plasteel(loc, rand(1,3))
	return INITIALIZE_HINT_QDEL

/obj/random/materials/wood_scrap/atom_init()
	..()
	new /obj/item/stack/sheet/wood(loc, rand(3,8))
	return INITIALIZE_HINT_QDEL

