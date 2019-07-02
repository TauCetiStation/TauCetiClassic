/obj/item/weapon/gun/projectile/modulargun/auto_gun
	name = "gun"
	parsed = FALSE
	var/chamber_type = /obj/item/modular/chamber/medium/duolas
	var/barrel_type = /obj/item/modular/barrel/large/laser_rifle
	var/grip_type = /obj/item/modular/grip/large/rifle
	var/magazine_module_type = /obj/item/weapon/stock_parts/cell/super
	var/list/obj/item/ammo_casing/lens1 = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/laser)
	var/list/obj/item/modular/accessory/all_accessory = list(/obj/item/modular/accessory/optical/large)
	var/selfrecharging = FALSE

/obj/item/weapon/gun/projectile/modulargun/auto_gun/atom_init()
	.=..()
	standard_fire_delay = fire_delay
	barrel = new barrel_type(src)
	grip = new grip_type(src)
	chamber = new chamber_type(src)
	magazine_module = new magazine_module_type(src)
	if(istype(magazine_module, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/modul = magazine_module
		modul.modular_cell = TRUE
		modul.icon_mem = icon_state
		modul.icon = 'code/modules/projectiles/modules/modular.dmi'
		modul.icon_state = "magazine_charge_icon"
		modul.item_state = "magazine_charge_icon"
		modul.update_icon()

	if(chamber)
		chamber.parent = src
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
		barrel.parent = src
		lessdamage += barrel.lessdamage
		lessdispersion += barrel.lessdispersion
		lessfiredelay += barrel.lessfiredelay
		lessrecoil += barrel.lessrecoil
		size += barrel.size
		if(istype(barrel, /obj/item/modular))
			if(barrel.icon_overlay)
				overlays += barrel.icon_overlay

	if(grip)
		grip.parent = src
		lessdamage += grip.lessdamage
		lessdispersion += grip.lessdispersion
		lessfiredelay += grip.lessfiredelay
		lessrecoil += grip.lessrecoil
		size += grip.size
		if(istype(grip, /obj/item/modular))
			if(grip.icon_overlay)
				overlays += grip.icon_overlay
	if(magazine_module)
		magazine_module.parent = src
		if(istype(magazine_module, MAGAZINE_CELL))
			magazine_eject = FALSE
			power_supply = magazine_module
			cell_type = power_supply.type
			overlays += "magazine_charge"
			lessdamage += magazine_module.lessdamage
			lessdispersion += magazine_module.lessdispersion
			lessfiredelay += magazine_module.lessfiredelay
			lessrecoil += magazine_module.lessrecoil
			size += magazine_module.size

		else if(istype(magazine_module, MAGAZINE_INTERNAL))
			magazine_eject = FALSE
			mag_type = magazine_module.type
			magazine = magazine_module
			overlays += "magazine_internal"
			lessdamage += magazine_module.lessdamage
			lessdispersion += magazine_module.lessdispersion
			lessfiredelay += magazine_module.lessfiredelay
			lessrecoil += magazine_module.lessrecoil
			size += magazine_module.size

		else
			if(istype(magazine_module, MAGAZINE_EXTERNAL))
				magazine_eject = TRUE
				mag_type = magazine_module.type
				magazine = magazine_module
				overlays += "magazine_external"
				lessdamage += magazine_module.lessdamage
				lessdispersion += magazine_module.lessdispersion
				lessfiredelay += magazine_module.lessfiredelay
				lessrecoil += magazine_module.lessrecoil
				size += magazine_module.size

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
					modul.parent = src
					if(istype(modul, /obj/item/modular))
						if(modul.icon_overlay)
							modul.icon_state = modul.icon_overlay
							overlays += modul.icon_state
	if(all_accessory.len > 0)
		for(var/i in all_accessory)
			var/obj/item/modular/accessory/modul = new i(src)
			if((accessory_type.len == 0) || !(is_type_in_list(modul, accessory_type)))
				var/conflict_size = FALSE
				for(var/obj/item/modular/modules in contents)
					if(!is_type_in_list(modules, modul.modul_size) && !istype(modules, ACCESSORY) && gun_type in modul.gun_type)
						conflict_size = TRUE
				if(!conflict_size)
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
							modul.parent = src
							if(istype(modul, /obj/item/modular))
								if(modul.icon_overlay)
									overlays += modul.icon_overlay
							modul.activate()
							modul.parent = src
							update_icon()

	if(!core && selfrecharging)
		core = new SELF_RECHARGER(src)
		core.parent = src
		accessory.Add(core)
		accessory_type.Add(core.type)
		if(istype(core, SELF_RECHARGER))
			if(gun_energy && power_supply)
				size += core.size
				if(core.icon_overlay)
					overlays += core.icon_overlay
				START_PROCESSING(SSobj, src)

	collected = TRUE

	if(collected)
		size_value()
		update_icon()