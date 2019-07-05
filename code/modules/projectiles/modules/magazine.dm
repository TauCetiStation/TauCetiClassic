/obj/item/weapon/modul_gun/magazine
	name = "magazine"
	var/caliber
	var/obj/item/weapon/stock_parts/cell/power_supply
	var/eject_casing = TRUE

/obj/item/weapon/modul_gun/magazine/proc/get_round()
	return
/obj/item/weapon/modul_gun/magazine/proc/ammo_count()
	return
/obj/item/weapon/modul_gun/magazine/proc/give_round()
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

/obj/item/weapon/modul_gun/magazine/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	gun.magazine = null
	src.loc = get_turf(gun.loc)
//////////////////////////////////////////////ENERGY
/obj/item/weapon/modul_gun/magazine/energy
	name = "energy magazine"
	caliber = "energy"
	icon_state = "mag1_icon"
	icon_overlay = "mag1"

/obj/item/weapon/modul_gun/magazine/energy/condition_check(obj/item/weapon/gun_modular/gun)
	if(power_supply && gun.chamber && !gun.magazine)
		if(gun.chamber.caliber == caliber)
			return TRUE
	return FALSE

/obj/item/weapon/modul_gun/magazine/energy/attackby(obj/item/A, mob/user)
	if(CELL && !power_supply)
		var/obj/item/weapon/stock_parts/cell/cell = A
		power_supply = cell
		user.drop_item()
		cell.loc = src

/obj/item/weapon/modul_gun/magazine/energy/get_round()
	if (!parent.chamber.ammo_type || !power_supply)
		return
	var/shottype = parent.chamber.ammo_type[parent.chamber.select]
	var/obj/item/ammo_casing/energy/shot = new shottype(src)
	if(power_supply.charge < shot.e_cost)
		return
	power_supply.use(shot.e_cost * 10)
	return shot

/obj/item/weapon/modul_gun/magazine/energy/external
	name = "energy magazine external"

/obj/item/weapon/modul_gun/magazine/energy/external/attack_self(mob/user)
	external(user)

/obj/item/weapon/modul_gun/magazine/energy/internal
	name = "enery magazine internal"

/obj/item/weapon/modul_gun/magazine/energy/internal/attack_self(mob/user)
	return

//////////////////////////////////////////////BULLET
/obj/item/weapon/modul_gun/magazine/bullet
	name = "magazine"
	caliber = "9mm"
	var/list/stored_ammo = list()
	var/multiload
	var/max_ammo = 8
	var/mag_type
	var/mag_type2
	icon_state = "mag1_icon"
	icon_overlay = "mag1"

/obj/item/weapon/modul_gun/magazine/bullet/condition_check(obj/item/weapon/gun_modular/gun)
	if(gun.chamber && !gun.magazine)
		if(gun.chamber.caliber == caliber)
			return TRUE
	return FALSE

/obj/item/weapon/modul_gun/magazine/bullet/ammo_count()
	return stored_ammo.len

/obj/item/weapon/modul_gun/magazine/bullet/attackby(obj/item/A, mob/user, silent = 0)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/did_load = give_round(AC)
			if(did_load)
				AM.stored_ammo -= AC
				num_loaded++
			if(!did_load || !multiload)
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC))
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		if (!silent)
			to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()
		return num_loaded
	return FALSE

/obj/item/weapon/modul_gun/magazine/bullet/attack_self(mob/user)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		A.loc = get_turf(src.loc)
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You remove a shell from \the [src]!</span>")
		update_icon()

/obj/item/weapon/modul_gun/magazine/bullet/give_round(obj/item/ammo_casing/r)
	var/obj/item/ammo_casing/rb = r
	if (rb)
		if (stored_ammo.len < max_ammo && rb.caliber == caliber)
			stored_ammo += rb
			rb.loc = src
			return TRUE
	return FALSE

/obj/item/weapon/modul_gun/magazine/bullet/get_round()
	if (!stored_ammo.len)
		return null
	else
		var/obj/item/ammo_casing/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		return b

/obj/item/weapon/modul_gun/magazine/proc/internal(mob/user)
	return FALSE
/obj/item/weapon/modul_gun/magazine/proc/external(mob/user)
	if (parent.magazine)
		eject(parent)
		user.put_in_hands(src)
		update_icon()
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
		return TRUE
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon()
	return FALSE

/obj/item/weapon/modul_gun/magazine/bullet/external
	name = "magazine external"
	caliber = "9mm"
	max_ammo = 8

/obj/item/weapon/modul_gun/magazine/bullet/external/attack_self(mob/user)
	external(user)

/obj/item/weapon/modul_gun/magazine/bullet/internal
	name = "magazine internal"
	caliber = "357"
	max_ammo = 6
	eject_casing = FALSE

/obj/item/weapon/modul_gun/magazine/bullet/internal/attack_self(mob/user)
	var/num_unloaded = 0
	parent.chambered = null
	for(var/obj/item/ammo_casing/CB in contents)
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You unload [num_unloaded] shell\s from [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")



//////////////////////////////////////////////MODULES LASER
////////////////////////INTERNAL
/obj/item/weapon/modul_gun/magazine/energy/internal/normal
	name = "energy magazine internal"
	caliber = "energy"
	icon_state = "magazine_charge_icon"
	icon_overlay = "magazine_internal"
////////////////////////EXTERNAL
/obj/item/weapon/modul_gun/magazine/energy/external/normal
	name = "energy magazine external"
	caliber = "energy"
	icon_state = "magazine_charge_icon"
	icon_overlay = "magazine_charge"
//////////////////////////////////////////////MODULES BULLET
////////////////////////INTERNAL
/obj/item/weapon/modul_gun/magazine/bullet/internal/rus357
	name = "magazine internal 357"
	caliber = "357"
	max_ammo = 6
	icon_state = "magazine_internal_icon"
	icon_overlay = "magazine_internal"

/obj/item/weapon/modul_gun/magazine/bullet/internal/heavyrifle
	name = "magazine internal heavyrifle"
	caliber = "14.5mm"
	max_ammo = 1
	icon_state = "magazine_internal_icon"
	icon_overlay = "magazine_internal"

/obj/item/weapon/modul_gun/magazine/bullet/internal/shotgun
	name = "magazine internal shotgun"
	caliber = "shotgun"
	max_ammo = 8
	icon_state = "magazine_internal_icon"
	icon_overlay = "magazine_internal"
////////////////////////EXTERNAL
/obj/item/weapon/modul_gun/magazine/bullet/external/m9mm
	name = "magazine internal 9mm"
	caliber = "9mm"
	max_ammo = 8
	icon_state = "magazine_external_icon"
	icon_overlay = "magazine_external"