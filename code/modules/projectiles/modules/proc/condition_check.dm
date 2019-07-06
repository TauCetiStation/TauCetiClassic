/obj/item/weapon/modul_gun/grip/condition_check(obj/item/weapon/gun_modular/gun)
	return TRUE

/obj/item/weapon/modul_gun/barrel/condition_check(obj/item/weapon/gun_modular/gun)
	return TRUE

/obj/item/weapon/modul_gun/accessory/condition_check(obj/item/weapon/gun_modular/gun)
	if(gun.accessory.len < gun.max_accessory && !is_type_in_list(src, gun.accessory_type))
		return TRUE
	return FALSE

/obj/item/weapon/modul_gun/chamber/energy/condition_check(obj/item/weapon/gun_modular/gun)
	if(!gun.chamber && caliber == "energy" && ammo_type.len > 0)
		return TRUE
	return FALSE

/obj/item/weapon/modul_gun/chamber/bullet/condition_check(obj/item/weapon/gun_modular/gun)
	if(!gun.chamber)
		return TRUE
	return FALSE

/obj/item/weapon/modul_gun/magazine/energy/condition_check(obj/item/weapon/gun_modular/gun)
	if(power_supply && gun.chamber && !gun.magazine)
		if(gun.chamber.caliber == caliber)
			return TRUE
	return FALSE

/obj/item/weapon/modul_gun/magazine/bullet/condition_check(obj/item/weapon/gun_modular/gun)
	if(gun.chamber && !gun.magazine && mag_type)
		if(gun.chamber.caliber == caliber)
			return TRUE
	return FALSE

