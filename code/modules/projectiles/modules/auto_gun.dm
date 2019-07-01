/obj/item/weapon/gun/projectile/modulargun/auto_gun
	name = "gun"
	parsed = FALSE
	var/chamber_type = /obj/item/modular/chambered/duolas
	var/barrel_type = /obj/item/modular/barrel/large/laser_rifle
	var/grip_type = /obj/item/modular/grip/rifle
	var/magazine1in_type = /obj/item/weapon/stock_parts/cell/super
	var/list/obj/item/ammo_casing/lens1 = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/laser)
	var/list/obj/item/modular/accessory/all_accessory = list(/obj/item/modular/accessory/optical/large)

/obj/item/weapon/gun/projectile/modulargun/auto_gun/atom_init()
	.=..()
	standard_fire_delay = fire_delay
	barrel = new barrel_type(src)
	grip = new grip_type(src)
	chamber = new chamber_type(src)
	magazine1in = new magazine1in_type(src)
	if(istype(magazine1in, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/modul = magazine1in
		modul.modular_cell = TRUE
		modul.update_icon()

	if(chamber)
		caliber = chamber.caliber
		gun_type = chamber.gun_type
		gun_energy = chamber.gun_energy
		multi_type = chamber.multi_type
		type_cap = chamber.type_cap
		pellets = chamber.pellets
		charge_indicator = chamber.charge_indicator
		icon = 'code/modules/projectiles/modules/modular.dmi'
		icon_state = chamber.icon_overlay
		lessdamage += chamber.lessdamage
		lessdispersion += chamber.lessdispersion
		lessfiredelay += chamber.lessfiredelay
		lessrecoil += chamber.lessrecoil
		size += chamber.size
		if(istype(chamber, /obj/item/modular))
			if(chamber.icon_overlay)
				overlays += chamber.icon_overlay
	if(barrel)
		lessdamage += barrel.lessdamage
		lessdispersion += barrel.lessdispersion
		lessfiredelay += barrel.lessfiredelay
		lessrecoil += barrel.lessrecoil
		size += barrel.size
		if(istype(barrel, /obj/item/modular))
			if(barrel.icon_overlay)
				overlays += barrel.icon_overlay

	if(grip)
		lessdamage += grip.lessdamage
		lessdispersion += grip.lessdispersion
		lessfiredelay += grip.lessfiredelay
		lessrecoil += grip.lessrecoil
		size += grip.size
		if(istype(grip, /obj/item/modular))
			if(grip.icon_overlay)
				overlays += grip.icon_overlay

	if(istype(magazine1in, /obj/item/weapon/stock_parts/cell))
		magazine_eject = FALSE
		power_supply = magazine1in
		cell_type = power_supply.type
		overlays += "magazine_charge"
		lessdamage += magazine1in.lessdamage
		lessdispersion += magazine1in.lessdispersion
		lessfiredelay += magazine1in.lessfiredelay
		lessrecoil += magazine1in.lessrecoil
		size += magazine1in.size

	else if(istype(magazine1in, /obj/item/ammo_box/magazine/internal))
		magazine_eject = FALSE
		mag_type = magazine1in.type
		magazine = magazine1in
		overlays += "magazine_internal"
		lessdamage += magazine1in.lessdamage
		lessdispersion += magazine1in.lessdispersion
		lessfiredelay += magazine1in.lessfiredelay
		lessrecoil += magazine1in.lessrecoil
		size += magazine1in.size

	else
		if(istype(magazine1in, /obj/item/ammo_box/magazine))
			magazine_eject = TRUE
			mag_type = magazine1in.type
			magazine = magazine1in
			overlays += "magazine_external"
			lessdamage += magazine1in.lessdamage
			lessdispersion += magazine1in.lessdispersion
			lessfiredelay += magazine1in.lessfiredelay
			lessrecoil += magazine1in.lessrecoil
			size += magazine1in.size
	if(lens1.len > 0)
		for(var/i in lens1)
			var/obj/item/ammo_casing/energy/modul = new i(src)
			if(gun_energy && istype(modul, /obj/item/ammo_casing/energy))
				if(modul.caliber == caliber)
					if(multi_type && ammo_type.len < type_cap)
						ammo_type += modul
						lens.Add(modul)
					else if(!multi_type && ammo_type.len == 0)
						ammo_type += modul
						lens.Add(modul)
					lessdamage += modul.lessdamage
					lessdispersion += modul.lessdispersion
					lessfiredelay += modul.lessfiredelay
					lessrecoil += modul.lessrecoil
					size += modul.size
					if(istype(modul, /obj/item/modular))
						if(modul.icon_overlay)
							modul.icon_state = modul.icon_overlay
							overlays += modul.icon_state
	if(all_accessory.len > 0)
		for(var/i in all_accessory)
			var/obj/item/modular/accessory/modul = new i(src)
			if((accessory_type.len == 0) || !(is_type_in_list(modul, accessory_type)))
				if(is_type_in_list(barrel, modul.barrel_size) && gun_type in modul.gun_type)
					if(accessory.len < max_accessory)
						var/conflict = FALSE
						for(var/o in modul.conflicts)
							if(is_type_in_list(o, contents))
								conflict = TRUE
						if(!conflict)
							accessory.Add(modul)
							accessory_type.Add(modul.type)
							lessdamage += modul.lessdamage
							lessdispersion += modul.lessdispersion
							lessfiredelay += modul.lessfiredelay
							lessrecoil += modul.lessrecoil
							size += modul.size
							if(istype(modul, /obj/item/modular))
								if(modul.icon_overlay)
									overlays += modul.icon_overlay
							modul.fixation = TRUE
							modul.parent = src
							update_icon()

	collected = TRUE

	if(collected)
		size_value()

		if(gun_energy)
			power_supply.maxcharge /= 10
			power_supply.charge /= 10

		var/weapon_size
		var/magazine_ejected

		if(magazine_eject)
			magazine_ejected = "external"
		else
			magazine_ejected = "internal"

		if(w_class == ITEM_SIZE_SMALL)
			weapon_size = "Small"
		if(w_class == ITEM_SIZE_NORMAL)
			weapon_size = "Medium"
		if(w_class == ITEM_SIZE_LARGE)
			weapon_size = "Big"

		name = "[weapon_size] weapon [gun_type] [caliber] gun"
		desc = "Assembly completed \the [src]. Weapon Type - [gun_type]. Weapon size - [weapon_size]. Caliber - [caliber]. Type store - [magazine_ejected]."
		update_icon()