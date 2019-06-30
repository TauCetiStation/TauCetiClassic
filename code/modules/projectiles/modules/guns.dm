/obj/item/weapon/gun/projectile/modulargun/gun
	name = "gun"
	var/barrel_type = /obj/item/modular/barrel/large
	var/grip_type = /obj/item/modular/grip/resilient
	var/chamber_type = /obj/item/modular/chambered/duolas
	var/magazine1in_type = /obj/item/weapon/stock_parts/cell/super
	var/obj/item/ammo_casing/energy/lens1_type = /obj/item/ammo_casing/energy/laser
	var/obj/item/ammo_casing/energy/lens2_type = /obj/item/ammo_casing/energy/electrode
	var/list/obj/item/ammo_casing/lens1 = list()

/obj/item/weapon/gun/projectile/modulargun/gun/atom_init()
	.=..()
	barrel = new barrel_type(src)
	grip = new grip_type(src)
	chamber = new chamber_type(src)
	magazine1in = new magazine1in_type(src)
	if(istype(magazine1in, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/modul = magazine1in
		modul.modular_cell = TRUE
		modul.update_icon()
	var/obj/item/ammo_casing/energy/lens1 = new lens1_type(src)
	var/obj/item/ammo_casing/energy/lens2 = new lens2_type(src)
	lens1 = list(lens1, lens2)
	if(chamber)
		attach(chamber, TRUE, null, FALSE)
		if(barrel)
			attach(barrel, TRUE, null, FALSE)
			if(magazine1in)
				attach(magazine1in, TRUE, null, FALSE)
				if(gun_energy && lens)
					for(var/obj/item/ammo_casing/energy/i in lens1)
						attach(i, TRUE, null, FALSE)
				collect(null, FALSE)
