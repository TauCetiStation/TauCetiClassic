/obj/item/weapon/modul_gun/accessory
	name = "accessory"

/obj/item/weapon/modul_gun/accessory/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(gun.accessory.len < gun.max_accessory && is_type_in_list(src, gun.accessory_type))
		parent = gun
		gun.accessory.Add(src)
		gun.accessory_type.Add(src.type)
		src.loc = gun
	else
		return

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