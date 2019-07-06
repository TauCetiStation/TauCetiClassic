/obj/item/weapon/modul_gun/accessory/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		gun.accessory.Add(src)
		gun.accessory_type.Add(src.type)
		src.loc = gun
		user_parent = gun.user_parent
		parent.overlays += icon_overlay
		change_stat(gun, TRUE)
	else
		return

/obj/item/weapon/modul_gun/barrel/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		gun.barrel = src
		src.loc = gun
		parent.overlays += icon_overlay
		change_stat(gun, TRUE)
	else
		return

/obj/item/weapon/modul_gun/chamber/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		src.loc = gun
		parent.chamber = src
		parent.recoil += recoil
		parent.fire_delay += fire_delay
		parent.overlays += icon_overlay
		change_stat(gun, TRUE)
	else
		return

/obj/item/weapon/modul_gun/grip/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		parent.grip = src
		src.loc = parent
		parent.overlays += icon_overlay
		change_stat(gun, TRUE)
	else
		return

/obj/item/weapon/modul_gun/magazine/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		parent.magazine = src
		src.loc = gun
		change_stat(gun, TRUE)
	else
		return

