/obj/item/weapon/gun/projectile/modulargun/gun
	name = "gun"
	var/barrel_type = /obj/item/modular/barrel/large
	var/grip_type = /obj/item/modular/grip/resilient
	var/chamber_type = /obj/item/modular/chambered/duolas
	var/magazine1in_type = /obj/item/weapon/stock_parts/cell/super
	var/obj/item/ammo_casing/energy/lens1_type = /obj/item/ammo_casing/energy/laser
	var/obj/item/ammo_casing/energy/lens2_type = /obj/item/ammo_casing/energy/electrode

/obj/item/weapon/gun/projectile/modulargun/gun/atom_init()
	barrel = new barrel_type(src)
	grip = new grip_type(src)
	chamber = new chamber_type(src)
	magazine1in = new magazine1in_type(src)
	var/obj/item/ammo_casing/energy/lens1 = new lens1_type(src)
	var/obj/item/ammo_casing/energy/lens2 = new lens2_type(src)
	lens = list(lens1, lens2)
	.=..()
