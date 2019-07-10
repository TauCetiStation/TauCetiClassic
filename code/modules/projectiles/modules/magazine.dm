/obj/item/weapon/modul_gun/magazine
	name = "magazine"
	var/caliber
	var/obj/item/weapon/stock_parts/cell/power_supply = null
	var/obj/item/ammo_box/magazine/magazine = null
	var/eject_casing = TRUE

/obj/item/weapon/modul_gun/magazine/proc/get_round()
	return magazine.get_round()
/obj/item/weapon/modul_gun/magazine/proc/ammo_count()
	return magazine.ammo_count()
/obj/item/weapon/modul_gun/magazine/proc/give_round()
	return magazine.give_round()
//////////////////////////////////////////////ENERGY
/obj/item/weapon/modul_gun/magazine/energy
	name = "energy magazine"
	caliber = "energy"
	icon_state = "magazine_charge"
	icon_overlay = "magazine_charge_icon"
	eject_casing = FALSE

/obj/item/weapon/modul_gun/magazine/energy/attackby(obj/item/A, mob/user)
	if(CELL && !power_supply)
		var/obj/item/weapon/stock_parts/cell/cell = A
		power_supply = cell
		user.drop_item()
		cell.loc = src

/obj/item/weapon/modul_gun/magazine/energy/attack_self(mob/user)
	..()
	to_chat(user, "<span class='warning'>*click*</span>")
	playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/modul_gun/magazine/energy/get_round(obj/item/ammo_casing/energy/ammo)
	if(power_supply)
		if(ammo.e_cost * 10 < power_supply.charge)
			var/obj/item/ammo_casing/energy/shot = new ammo.type(src)
			power_supply.use(shot.e_cost * 10)
			return shot
	return null

/obj/item/weapon/modul_gun/magazine/energy/ammo_count(obj/item/ammo_casing/energy/ammo)
	if(power_supply)
		return power_supply.charge / ammo.e_cost * 10

/obj/item/weapon/modul_gun/magazine/energy/give_round()
	return FALSE

//////////////////////////////////////////////BULLET
/obj/item/weapon/modul_gun/magazine/bullet
	name = "bullet magazine"
	caliber = "9mm"
	icon_state = "magazine_external_icon"
	icon_overlay = "magazine_external"
	var/mag_type = null
	var/mag_type2 = null

/obj/item/weapon/modul_gun/magazine/bullet/attackby(obj/item/A, mob/user)
	if(MAGAZINE && !magazine)
		var/obj/item/ammo_box/magazine/modul = A
		if(!mag_type)
			if(modul.caliber == caliber)
				mag_type = modul.type
		if(istype(modul, mag_type))
			user.drop_item()
			modul.loc = src
			magazine = modul

	if(MAGAZINE && !magazine)
		var/obj/item/ammo_box/magazine/modul = A
		if(!mag_type2)
			if(modul.caliber == caliber)
				mag_type2 = modul.type
		if(istype(modul, mag_type2))
			user.drop_item()
			modul.loc = src
			magazine = modul

