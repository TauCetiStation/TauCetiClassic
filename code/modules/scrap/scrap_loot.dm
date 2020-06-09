//item holders generators
/obj/preset/storage
	var/ammo_type = ""

/obj/preset/storage/atom_init()
	..()
	var/obj/item/weapon/storage/backpack/kitbag/container = new(loc)
	for(var/x = 1 to 7)
		new ammo_type(container)
	return INITIALIZE_HINT_QDEL

/obj/preset/storage/weapons/light
	ammo_type = /obj/random/guns/set_9mm

/obj/preset/storage/weapons/medium
	ammo_type = /obj/random/guns/set_shotgun

/obj/preset/storage/weapons/heavy
	ammo_type = /obj/random/guns/set_357

/obj/preset/storage/weapons/random/atom_init()
	ammo_type = pick(prob(3);/obj/random/guns/set_9mm,\
					prob(2);/obj/random/guns/set_shotgun,\
					prob(1);/obj/random/guns/set_357)
	. = ..()


/obj/item/blueprints/junkyard
	color = "yellow"
	name = "build plans"
	desc = "Automatic shelter schematics. Warning: Single use only!"
	var/used = 0
	greedy = 1
	max_area_size = 150

/obj/item/blueprints/junkyard/interact()
	if(!used)
		create_area()
	else
		qdel(src)

/obj/item/blueprints/junkyard/create_area()
	used = 1
	..()
