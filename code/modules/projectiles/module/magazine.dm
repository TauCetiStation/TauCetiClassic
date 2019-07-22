/obj/item/weapon/gun_module/magazine
	name = "gun magazine"
	icon_state = "magazine_external_icon"
	icon_overlay = "magaine_external"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	var/external = TRUE
	var/caliber
	attackbying = INTERRUPT
	attackself = INTERRUPT

/obj/item/weapon/gun_module/magazine/attach(GUN)
	if(condition_check(gun))
		gun.magazine_supply = src
		parent = gun
		src.loc = parent
		change_stat(gun, TRUE)
		gun.overlays += icon_overlay
		gun.modules += src
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/magazine/condition_check(GUN)
	if(!gun.magazine_supply && gun.chamber && caliber == gun.chamber.caliber)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/magazine/eject(GUN)
	gun.magazine_supply = null
	src.loc = get_turf(gun.loc)
	parent = null
	change_stat(gun, FALSE)
	gun.modules -= src

/obj/item/weapon/gun_module/magazine/proc/ammo_count()
	return

/obj/item/weapon/gun_module/magazine/proc/get_round()
	return null

/obj/item/weapon/gun_module/magazine/attack_self(mob/user)
	..()

//////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun_module/magazine/energy
	name = "gun energy magazine"
	icon_state = "magazine_charge_icon"
	icon_overlay = "magaine_charge"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	caliber = ENERGY
	var/obj/item/weapon/stock_parts/cell/power_supply = null

/obj/item/weapon/gun_module/magazine/energy/attackby(obj/item/A, mob/user)
	if(CELL && !power_supply)
		power_supply = A
		user.drop_item()
		power_supply.loc = src
	if(isscrewdriver(A))
		if(power_supply)
			power_supply.loc = get_turf(src.loc)
			power_supply = null

/obj/item/weapon/gun_module/magazine/energy/attack_self(mob/user)
	if(external && power_supply)
		power_supply.loc = get_turf(parent.loc)
		power_supply.update_icon()
		user.put_in_hands(power_supply)
		power_supply = null

/obj/item/weapon/gun_module/magazine/energy/ammo_count(var/obj/item/ammo_casing/energy/ammo = null)
	if(ammo == null)
		return FALSE
	if(power_supply)
		var/obj/item/ammo_casing/energy/shot = new ammo.type(src)
		if(power_supply.charge > (shot.e_cost * 10))
			return TRUE
	return FALSE

/obj/item/weapon/gun_module/magazine/energy/get_round(obj/item/ammo_casing/energy/ammo)
	if(power_supply)
		var/obj/item/ammo_casing/energy/shot = new ammo.type(src)
		power_supply.use(shot.e_cost * 10)
		return shot
	return null

//////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun_module/magazine/bullet
	name = "gun energy magazine"
	icon_state = "magazine_charge_icon"
	icon_overlay = "magaine_charge"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	caliber = "9mm"
	var/obj/item/ammo_box/magazine/bullet_supply = null
	var/list/stored_ammo
	var/mag_type = null
	var/mag_type2 = null

/obj/item/weapon/gun_module/magazine/bullet/attackby(obj/item/A, mob/user)
	if(MAGAZINE && !bullet_supply)
		var/obj/item/ammo_box/magazine/modul = A
		if(!mag_type)
			if(modul.caliber == caliber)
				mag_type = modul.type
		if(istype(modul, mag_type))
			user.drop_item()
			modul.loc = src
			bullet_supply = modul

		if(!mag_type2 && !istype(modul, mag_type))
			if(modul.caliber == caliber)
				mag_type2 = modul.type
		if(istype(modul, mag_type2))
			user.drop_item()
			modul.loc = src
			bullet_supply = modul

/obj/item/weapon/gun_module/magazine/bullet/attack_self(mob/user)
	if(external && bullet_supply)
		bullet_supply.loc = get_turf(parent.loc)
		bullet_supply.update_icon()
		user.put_in_hands(bullet_supply)
		bullet_supply = null

/obj/item/weapon/gun_module/magazine/bullet/ammo_count()
	if(bullet_supply)
		return bullet_supply.ammo_count()

/obj/item/weapon/gun_module/magazine/bullet/get_round()
	if(bullet_supply)
		return bullet_supply.get_round()