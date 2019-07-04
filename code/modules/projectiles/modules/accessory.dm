/obj/item/weapon/modul_gun/accessory
	name = "accessory"

/obj/item/weapon/modul_gun/accessory/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		gun.accessory.Add(src)
		gun.accessory_type.Add(src.type)
		src.loc = gun
		parent.overlays += icon_overlay
		change_stat(gun, TRUE)
	else
		return
/obj/item/weapon/modul_gun/accessory/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.accessory.Remove(src)
	gun.accessory_type.Remove(src.type)
	src.loc = get_turf(gun.loc)

/obj/item/weapon/modul_gun/accessory/condition_check(obj/item/weapon/gun_modular/gun)
	if(gun.accessory.len < gun.max_accessory && !is_type_in_list(src, gun.accessory_type))
		return TRUE
	return FALSE
/obj/item/weapon/modul_gun/accessory/action
	name = "accessory action"
	var/attacked = TRUE
	var/attacked_self = TRUE
	var/active = FALSE

/obj/item/weapon/modul_gun/accessory/passive
	name = "accessory_passive"

/obj/item/weapon/modul_gun/accessory/action/attackby(obj/item/A, mob/user)
	if(!attacked)
		return

/obj/item/weapon/modul_gun/accessory/action/attack_self(mob/user)
	if(!attacked_self)
		return
	active = !active