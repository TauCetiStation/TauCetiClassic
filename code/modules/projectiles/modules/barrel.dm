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

////////////////////////BARREL
/obj/item/weapon/modul_gun/barrel/small
	name = "barrel small"
	icon_state = "barrel_small_icon"
	icon_overlay = "barrel_small"
	lessdamage = 7
	lessdispersion = -1
	lessrecoil = 3
	size = 1

/obj/item/weapon/modul_gun/barrel/medium
	name = "barrel medium"
	icon_state = "barrel_medium_icon"
	icon_overlay = "barrel_medium"
	lessdamage = 4
	lessdispersion = 1
	lessrecoil = 1
	size = 2

/obj/item/weapon/modul_gun/barrel/large
	name = "barrel large"
	icon_state = "barrel_large_icon"
	icon_overlay = "barrel_large"
	lessdamage = 1
	lessdispersion = 2
	lessrecoil = -1
	size = 3

/obj/item/weapon/modul_gun/barrel/rifle
	name = "barrel rifle"
	icon_state = "barrel_large_bullet"
	icon_overlay = "barrel_large_bullet"
	lessdamage = -1
	lessdispersion = 1
	lessrecoil = -2
	size = 3

/obj/item/weapon/modul_gun/barrel/medium_rifle
	name = "barrel medium rifle"
	icon_state = "barrel_medium_bullet"
	icon_overlay = "barrel_medium_bullet"
	lessdamage = 3
	lessdispersion = 1
	lessrecoil = 1
	size = 3