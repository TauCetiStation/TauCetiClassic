/obj/item/weapon/modul_gun/barrel
	name = "barrel"

/obj/item/weapon/modul_gun/barrel/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	parent = gun
	gun.barrel = src
	src.loc = gun