/obj/item/weapon/modul_gun/accessory/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	user_parent = null
	gun.accessory.Remove(src)
	gun.accessory_type.Remove(src.type)
	src.loc = get_turf(gun.loc)

/obj/item/weapon/modul_gun/barrel/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.barrel = null
	src.loc = get_turf(gun.loc)

/obj/item/weapon/modul_gun/chamber/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.chamber = null
	gun.recoil -= recoil
	gun.fire_delay -= fire_delay
	src.loc = get_turf(gun.loc)

/obj/item/weapon/modul_gun/grip/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.grip = null
	src.loc = get_turf(gun.loc)

/obj/item/weapon/modul_gun/magazine/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.magazine = null
	src.loc = get_turf(gun.loc)