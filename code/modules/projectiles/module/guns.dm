/obj/item/weapon/gunmodule/gun
	name = "gun"
	var/chamber_type = /obj/item/weapon/gun_module/chamber/energy
	var/barrel_type = /obj/item/weapon/gun_module/barrel/energy
	var/grip_type = /obj/item/weapon/gun_module/grip
	var/magazine_type = /obj/item/weapon/gun_module/magazine/energy
	var/list/modules_type = list(/obj/item/weapon/gun_module/accessory/optical)
	var/list/attach_magazine = list()
	var/list/attach_chamber = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/stun)

/obj/item/weapon/gunmodule/gun/atom_init()
	var/obj/item/weapon/gun_module/chamber/new_chamber = new chamber_type(src)
	for(var/obj/item/ammo_casing/lens in attach_chamber)
		new_chamber.attackby(lens)
	new_chamber.attach(src)
	var/obj/item/weapon/gun_module/barrel/new_barrel = new barrel_type(src)
	new_barrel.attach(src)
	var/obj/item/weapon/gun_module/grip/new_grip = new grip_type(src)
	new_grip.attach(src)
	var/obj/item/weapon/gun_module/magazine/new_magazine = new magazine_type(src)
	for(var/obj/item/ammo_box/magazine in attach_magazine)
		new_magazine.attackby(magazine)
	new_magazine.attach(src)
	..()