//TOOLS RANDOM
/obj/random/materials
	name = "Random Material"
	desc = "This is a random tool."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-metal"

/obj/random/materials/rods_scrap/New(var/newloc)
	new /obj/item/stack/rods/(newloc, rand(3,8))
	qdel(src)

/obj/random/materials/plastic_scrap/New(var/newloc)
	new /obj/item/stack/sheet/mineral/plastic(newloc, rand(5,10))
	qdel(src)

/obj/random/materials/metal_scrap/New(var/newloc)
	new /obj/item/stack/sheet/metal(newloc, rand(8,12))
	qdel(src)

/obj/random/materials/glass_scrap/New(var/newloc)
	new /obj/item/stack/sheet/glass(newloc, rand(5,10))
	qdel(src)

/obj/random/materials/plasteel_scrap/New(var/newloc)
	new /obj/item/stack/sheet/plasteel(newloc, rand(1,3))
	qdel(src)

/obj/random/materials/wood_scrap/New(var/newloc)
	new /obj/item/stack/sheet/wood(newloc, rand(3,8))
	qdel(src)

