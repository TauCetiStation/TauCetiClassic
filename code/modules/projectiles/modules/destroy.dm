/obj/item/weapon/gun/projectile/modulargun/Destroy()
	var/list/check = list() + contents + accessory
	for(var/obj/item/i in check)
		clear_ref(i)
	if(delete_all)
		for(var/obj/item/i in check)
			qdel(i)
	return ..()
/obj/item/weapon/gun/projectile/modulargun/proc/clear_ref(var/obj/item/command)
	if(istype(command, CHAMBER))
		var/obj/item/modular/chamber/modul = command
		caliber = null
		gun_type = null
		gun_energy = null
		multi_type = null
		type_cap = null
		pellets = null
		charge_indicator = null
		lessdamage -= chamber.lessdamage
		lessdispersion -= chamber.lessdispersion
		lessfiredelay -= chamber.lessfiredelay
		lessrecoil -= chamber.lessrecoil
		size -= chamber.size
		if(istype(chamber, /obj/item/modular))
			if(chamber.icon_overlay)
				overlays -= chamber.icon_overlay
		chamber = null
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, BARREL))
		var/obj/item/modular/barrel/modul = command
		lessdamage -= barrel.lessdamage
		lessdispersion -= barrel.lessdispersion
		lessfiredelay -= barrel.lessfiredelay
		lessrecoil -= barrel.lessrecoil
		size -= barrel.size
		if(istype(barrel, /obj/item/modular))
			if(barrel.icon_overlay)
				overlays += barrel.icon_overlay
		barrel = null
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, GRIP))
		var/obj/item/modular/grip/modul = command
		lessdamage -= grip.lessdamage
		lessdispersion -= grip.lessdispersion
		lessfiredelay -= grip.lessfiredelay
		lessrecoil -= grip.lessrecoil
		size -= grip.size
		if(istype(grip, /obj/item/modular))
			if(grip.icon_overlay)
				overlays -= grip.icon_overlay
		grip = null
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, MAGAZINE_CELL))
		var/obj/item/weapon/stock_parts/cell/modul = command
		magazine_eject = FALSE
		power_supply = null
		cell_type = null
		overlays -= "magazine_charge"
		lessdamage -= magazine_module.lessdamage
		lessdispersion -= magazine_module.lessdispersion
		lessfiredelay -= magazine_module.lessfiredelay
		lessrecoil -= magazine_module.lessrecoil
		size -= magazine_module.size
		magazine_module = null
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, MAGAZINE_EXTERNAL))
		var/obj/item/ammo_box/magazine/modul = command
		magazine_eject = null
		mag_type = null
		magazine = null
		if(istype(magazine_module, MAGAZINE_INTERNAL))
			overlays -= "magazine_internal"
		else
			overlays -= "magazine_external"
		lessdamage -= magazine_module.lessdamage
		lessdispersion -= magazine_module.lessdispersion
		lessfiredelay -= magazine_module.lessfiredelay
		lessrecoil -= magazine_module.lessrecoil
		size -= magazine_module.size
		magazine_module = null
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, LENS))
		var/obj/item/ammo_casing/energy/modul = command
		ammo_type -= modul
		lens.Remove(modul)
		lessdamage -= modul.lessdamage
		lessdispersion -= modul.lessdispersion
		lessfiredelay -= modul.lessfiredelay
		lessrecoil -= modul.lessrecoil
		size -= modul.size
		if(istype(modul, /obj/item/modular))
			if(modul.icon_overlay)
				modul.icon_state = modul.icon_overlay
				overlays -= modul.icon_state
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, SELF_RECHARGER))
		var/obj/item/device/assembly/signaler/anomaly/modul = command
		size -= modul.size
		core = null
		accessory.Remove(modul)
		accessory_type.Remove(modul.type)
		contents.Remove(modul)
		modul.loc = get_turf(src.loc)
		modul.parent = null
		if(modul.icon_overlay)
			overlays -= modul.icon_overlay
		STOP_PROCESSING(SSobj, src)
		modul.loc = get_turf(src.loc)
		modul.parent = null

	if(istype(command, ACCESSORY))
		var/obj/item/modular/accessory/modul = command
		modul.deactivate()
		accessory.Remove(modul)
		accessory_type.Remove(modul.type)
		contents.Remove(modul)
		lessdamage -= modul.lessdamage
		lessdispersion -= modul.lessdispersion
		lessfiredelay -= modul.lessfiredelay
		lessrecoil -= modul.lessrecoil
		size -= modul.size
		if(modul.icon_overlay)
			overlays -= modul.icon_overlay
		modul.parent = null
		modul.loc = get_turf(src.loc)
	update_icon()

/obj/item/modular/Destroy()
	if(parent != null)
		parent.clear_ref(src)
	return ..()

/obj/item/device/assembly/signaler/anomaly/Destroy()
	if(parent != null)
		parent.clear_ref(src)
	return ..()

/obj/item/ammo_casing/Destroy()
	if(parent != null)
		parent.clear_ref(src)
	return ..()

/obj/item/ammo_box/magazine/Destroy()
	if(parent != null)
		parent.clear_ref(src)
	return ..()

/obj/item/weapon/stock_parts/cell/Destroy()
	if(parent != null)
		parent.clear_ref(src)
	return ..()