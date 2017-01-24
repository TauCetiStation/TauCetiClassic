//item holders generators
/obj/preset/storage/
	var/ammo_type = ""
/obj/preset/storage/New(var/newloc)
	var/obj/item/weapon/storage/backpack/kitbag/container = new /obj/item/weapon/storage/backpack/kitbag(newloc)
	for(var/x = 1 to 7)
		new ammo_type(container)
	qdel(src)

/obj/preset/storage/weapons/light/
	ammo_type = /obj/random/guns/set_9mm

/obj/preset/storage/weapons/medium/
	ammo_type = /obj/random/guns/set_shotgun

/obj/preset/storage/weapons/heavy/
	ammo_type = /obj/random/guns/set_357

/obj/preset/storage/weapons/random/New(var/newloc)
	ammo_type = pick(prob(3);/obj/random/guns/set_9mm,\
					prob(2);/obj/random/guns/set_shotgun,\
					prob(1);/obj/random/guns/set_357)
	..()
