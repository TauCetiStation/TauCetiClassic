/obj/item/weapon/modul_gun/barrel
	name = "barrel"
	icon_state = "bar1_icon"
	icon_overlay = "bar1"

/obj/item/weapon/modul_gun/barrel/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	parent = gun
	gun.barrel = src
	src.loc = gun
	parent.overlays += icon_overlay
	change_stat(gun, TRUE)

/obj/item/weapon/modul_gun/barrel/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.barrel = null
	src.loc = get_turf(gun.loc)