/obj/item/stack/rods/scrap/New(var/newloc)
	..(newloc, rand(3,8))

/obj/item/stack/sheet/mineral/plastic/scrap/New(var/newloc)
	..(newloc, rand(5,10))

/obj/item/stack/sheet/metal/scrap/New(var/newloc)
	..(newloc, rand(8,12))

/obj/item/stack/sheet/glass/scrap/New(var/newloc)
	..(newloc, rand(5,10))

/obj/item/stack/sheet/plasteel/scrap/New(var/newloc)
	..(newloc, rand(1,3))

/obj/item/stack/sheet/wood/scrap/New(var/newloc)
	..(newloc, rand(5,10))


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