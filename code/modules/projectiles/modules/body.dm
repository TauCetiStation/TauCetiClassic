/obj/item/weapon/gun/projectile/modulargun
	name = "The basis of the weapon"
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	desc = ""
	m_amt = 2000
	flags = CONDUCT
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_FLAGS_BELT
	magazine = null
	mag_type = null
	mag_type2 = null
	fire_delay = 12
	var/standard_fire_delay = 12

	var/obj/item/modular/barrel/barrel
	var/obj/item/modular/grip/grip
	var/obj/item/modular/chamber/chamber
	var/obj/item/ammo_box/magazine/magazine_module
	var/list/obj/item/ammo_casing/lens = list()
	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/list/obj/item/modular/accessory = list()
	var/list/accessory_type = list()
	var/obj/item/device/assembly/signaler/core


	var/cell_type
	var/modifystate = FALSE
	var/list/ammo_type = list()
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.

	var/magazine_eject
	var/gun_energy = FALSE
	var/multi_type = FALSE
	var/type_cap = 1
	var/isHandgun = FALSE
	var/parsed = TRUE

	var/collected = FALSE
	var/size = 0.0
	var/lessdamage = 0.0
	var/lessdispersion = 0.0
	var/lessfiredelay = 0
	var/lessrecoil = 0.0
	var/lessvariance = 0.0
	var/caliber
	var/gun_type
	var/max_accessory = 3
	var/pellets
	var/recharge_time = 3
	var/charge_tick = 0
	var/chargespeed = 1

	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	var/ratio = 0
	var/inited = FALSE
	var/charge_indicator = FALSE

/obj/item/modular
	icon = 'code/modules/projectiles/modules/modular.dmi'
	flags = CONDUCT
	var/icon_overlay
	var/size = 0.0
	var/lessdamage = 0.0
	var/lessdispersion = 0.0
	var/lessfiredelay = 0
	var/lessrecoil = 0.0
	var/gun_type
	m_amt = 500

/obj/item/modular/atom_init()
	.=..()
	pixel_x = rand(0, 10)
	pixel_y = rand(0, 10)

/obj/item/weapon/gun/projectile/modulargun/atom_init()
	.=..()

/obj/item/weapon/gun/projectile/modulargun/isHandgun()
	return isHandgun

/obj/item/weapon/gun/projectile/modulargun/process()
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100 * chargespeed)
	update_icon()

/obj/item/modular/atom_init()
	.=..()
	if(size <= 0.1)
		w_class = ITEM_SIZE_SMALL
	if(size > 0.2 && size <= 0.3)
		w_class = ITEM_SIZE_NORMAL
	if(size > 0.3)
		w_class = ITEM_SIZE_LARGE

/obj/item/weapon/gun/projectile/modulargun/proc/size_value()
	fire_delay = standard_fire_delay
	if(size <= 0.7)
		w_class = ITEM_SIZE_SMALL
		slot_flags = SLOT_FLAGS_BELT
		isHandgun = TRUE
	if(size > 0.7 && size <= 1.2)
		w_class = ITEM_SIZE_NORMAL
		slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK
		isHandgun = TRUE
	if(size > 1.2)
		w_class = ITEM_SIZE_LARGE
		slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK

	if(lessrecoil > 0.6)
		recoil = FALSE
	else
		recoil = TRUE

	fire_delay -= lessfiredelay

/obj/item/weapon/gun/projectile/modulargun/proc/collect(mob/user = null)
	if(collected)
		if(chamber && barrel && grip && magazine_module)
			size_value()
			initex()

			if(gun_energy)
				power_supply.maxcharge = power_supply.start_maxcharge / 10
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
			for(var/obj/item/i in contents)
				if(i.m_amt)
					m_amt += i.m_amt

			desc = "Assembly completed \the [src]. Weapon Type - [gun_type]. Weapon size - [weapon_size]. Caliber - [caliber]. Type store - [magazine_ejected]."
			to_chat(user, "<span class='notice'>Assembly completed \the [src]. Weapon Type - [gun_type]. Weapon size - [weapon_size]. Caliber - [caliber]. Type store - [magazine_ejected].</span>")
	else
		to_chat(user, "<span class='notice'>Disassembly completed \the [src].")
		name = "The basis of the weapon"
		fire_delay = standard_fire_delay
		if(gun_energy)
			power_supply.maxcharge = power_supply.start_maxcharge
			power_supply.charge *= 10

		for(var/obj/item/i in accessory)
			if(i in contents)
				contents.Remove(i)
			if(i in user.contents)
				user.contents.Remove(i)
			attach(i, FALSE, user)

/obj/item/weapon/gun/projectile/modulargun/proc/initex()
	if(collected)
		if(gun_energy)
			select = 1
			if(!inited)
				fire_sound = ammo_type[select].fire_sound
				inited = !inited
			update_icon()
		else
			chamber_round()
			fire_sound = chambered.fire_sound
			update_icon()

/obj/item/weapon/gun/projectile/modulargun/proc/attach(obj/item/modular/modul, var/attach, mob/user = null)
	var/success = FALSE
	if(attach)
		if(!chamber && istype(modul, CHAMBER))
			success = chamber_attach(modul, attach, user)

		if(gun_energy && istype(modul, LENS))
			success = lens_attach(modul, attach, user)

		if(chamber && gun_energy && !power_supply && istype(modul, MAGAZINE_CELL))
			success = magazine_attach(modul, attach, user)

		else if(chamber && !gun_energy && istype(modul, MAGAZINE_INTERNAL))
			success = magazine_attach(modul, attach, user)

		else
			if(chamber && !gun_energy && istype(modul, MAGAZINE_EXTERNAL))
				success = magazine_attach(modul, attach, user)

		if(chamber && !barrel && istype(modul, BARREL))
			success = barrel_attach(modul, attach, user)

		if(chamber && !grip && istype(modul, GRIP))
			success = grip_attach(modul, attach, user)

		if(chamber && gun_energy && istype(modul, SELF_RECHARGER))
			success = core_attach(modul, attach, user)

		if(chamber && barrel && istype(modul, ACCESSORY))
			success = accessory_attach(modul, attach, user)

		size_value()
		update_icon()
	else
		if(istype(modul, CHAMBER))
			success = chamber_attach(modul, attach, user)

		if(istype(modul, BARREL))
			success = barrel_attach(modul, attach, user)

		if(istype(modul, GRIP))
			success = grip_attach(modul, attach, user)

		if(istype(modul, MAGAZINE_CELL))
			success = magazine_attach(modul, attach, user)

		if(istype(modul, MAGAZINE_EXTERNAL))
			success = magazine_attach(modul, attach, user)

		if(istype(modul, LENS))
			success = lens_attach(modul, attach, user)

		if(istype(modul, ACCESSORY))
			success = accessory_attach(modul, FALSE, user)

		if(istype(modul, SELF_RECHARGER))
			success = core_attach(modul, FALSE, user)
		size_value()
		update_icon()
	return success

/obj/item/weapon/gun/projectile/modulargun/attackby(obj/item/A, mob/user)
	if(collected)
		if(magazine && collected && !magazine_eject)
			var/num_loaded = magazine.attackby(A, user, 1)
			if(num_loaded)
				playsound(src, 'sound/weapons/guns/reload_shotgun.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
				A.update_icon()
				update_icon()
				chamber_round()

		if (istype(A, MAGAZINE_EXTERNAL) && magazine_eject)
			var/obj/item/ammo_box/magazine/AM = A
			if (!magazine && (istype(AM, mag_type) || (istype(AM, mag_type2) && mag_type != null)) && AM.caliber == caliber)
				user.remove_from_mob(AM)
				magazine = AM
				magazine.loc = src
				overlays += "magazine_external"
				playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
				chamber_round()
				A.update_icon()
				update_icon()
				return TRUE
			else if(!magazine && !mag_type2 && istype(AM, MAGAZINE_EXTERNAL) && AM.caliber == caliber)
				user.remove_from_mob(AM)
				magazine = AM
				magazine.loc = src
				overlays += "magazine_external"
				playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
				chamber_round()
				A.update_icon()
				update_icon()
				return TRUE
			else if (magazine)
				to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")
		if(accessory)
			for(var/obj/item/modular/accessory/modul in accessory)
				modul.attackby(A, user)

	if(!collected)
		if(istype(A, CHAMBER))
			var/obj/item/modular/chamber/modul = A
			if(attach(modul, TRUE, user))
				to_chat(user, "<span class='notice'>Chamber installed \the [src]. Type gun [gun_type]. Caliber [caliber].</span>")

		if(istype(A, BARREL))
			var/obj/item/modular/barrel/modul = A
			if(gun_type in modul.gun_type)
				if(attach(modul, TRUE, user))
					to_chat(user, "<span class='notice'>Barrel installed \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the type \the [src].</span>")

		if(istype(A, GRIP))
			var/obj/item/modular/grip/modul = A
			if(gun_type in modul.gun_type)
				if(attach(modul, TRUE, user))
					to_chat(user, "<span class='notice'>Handle installed \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the type \the [src].</span>")

		if(istype(A, MAGAZINE_CELL))
			var/obj/item/weapon/stock_parts/cell/modul = A
			if(gun_energy)
				if(modul.modular_cell)
					if(attach(modul, TRUE, user))
						to_chat(user, "<span class='notice'>Battery installed \the [src]. Type internal</span>")
				else
					to_chat(user, "<span class='notice'>Change the battery with a screwdriver.</span>")

		if(istype(A, LENS))
			var/obj/item/ammo_casing/energy/modul = A
			if(modul.caliber == caliber)
				if(multi_type && ammo_type.len < type_cap)
					if(attach(modul, TRUE, user))
						to_chat(user, "<span class='notice'>Crystal installed \the [src]. Type internal</span>")
				else if(!multi_type && ammo_type.len == 0)
					if(attach(modul, TRUE, user))
						to_chat(user, "<span class='notice'>Crystal installed \the [src]. Type internal</span>")
					else
						to_chat(user, "<span class='notice'>Crystal not installed \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the caliber \the [src].</span>")

		if(chamber && !magazine_module && istype(A, MAGAZINE_INTERNAL))
			var/obj/item/ammo_box/magazine/internal/modul = A
			if(modul.caliber == caliber)
				if(attach(modul, TRUE, user))
					to_chat(user, "<span class='notice'>Store installed \the [src]. Type internal</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the caliber \the [src].</span>")

		if(chamber && !magazine_module && istype(A, MAGAZINE_EXTERNAL))
			var/obj/item/ammo_box/magazine/modul = A
			if(modul.caliber == caliber)
				if(attach(modul, TRUE, user))
					to_chat(user, "<span class='notice'>Store installed \the [src]. Type external</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the caliber \the [src].</span>")

		if(iswrench(A))
			var/list/listmodules = list("Cancel")
			for(var/obj/item/i in contents)
				if(!istype(i, ACCESSORY))
					listmodules.Add(i)
			var/command = input(user, "Pull module", , "Cancel") in listmodules

			if(istype(command, CHAMBER))
				var/obj/item/modular/chamber/modul = command
				attach(modul, FALSE, user)

			if(istype(command, BARREL))
				var/obj/item/modular/barrel/modul = command
				attach(modul, FALSE, user)

			if(istype(command, GRIP))
				var/obj/item/modular/grip/modul = command
				attach(modul, FALSE, user)

			if(istype(command, MAGAZINE_CELL))
				var/obj/item/weapon/stock_parts/cell/modul = command
				attach(modul, FALSE, user)

			if(istype(command, MAGAZINE_EXTERNAL))
				var/obj/item/ammo_box/magazine/modul = command
				attach(modul, FALSE, user)

			if(istype(command, LENS))
				var/obj/item/ammo_casing/energy/modul = command
				attach(modul, FALSE, user)

			if(istype(command, SELF_RECHARGER))
				var/obj/item/device/assembly/signaler/anomaly/modul = command
				core_attach(modul, FALSE, user)

			update_icon()
	else
		if(istype(A, ACCESSORY))
			var/obj/item/modular/accessory/modul = A
			accessory_attach(modul, TRUE, user)

		else if(istype(A, SELF_RECHARGER))
			var/obj/item/device/assembly/signaler/anomaly/modul = A
			core_attach(modul, TRUE, user)
		else
			if(iswrench(A))
				var/list/listmodules = list("Cancel")
				for(var/obj/item/modular/accessory/i in accessory)
					listmodules.Add(i)
				var/command = input(user, "Pull module", , "Cancel") in listmodules
				if(istype(command, ACCESSORY))
					var/obj/item/modular/accessory/modul = command
					accessory_attach(modul, FALSE, user)
				else
					if(istype(command, SELF_RECHARGER))
						var/obj/item/device/assembly/signaler/anomaly/modul = core
						core_attach(modul, FALSE, user)

	if(parsed)
		if(isscrewdriver(A))
			if(gun_energy && lens.len > 0)
				collected = !collected
				collect(user)
			else
				if(!gun_energy)
					collected = !collected
					collect(user)
	else
		to_chat(user, "<span class='notice'>You can not disassemble this weapon.</span>")

/obj/item/weapon/gun/projectile/modulargun/attack_self(mob/living/user)
	if(collected)
		if (magazine && src && magazine_eject && !gun_energy)
			magazine.loc = get_turf(src.loc)
			user.put_in_hands(magazine)
			overlays -= "magazine_external"
			magazine.update_icon()
			magazine = null
			update_icon()
			playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
			return TRUE
		else if (magazine_eject && !gun_energy)
			to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
		else if(!gun_energy && !magazine_eject && gun_type == SHOTGUN)
			if(recentpump)
				return
			pump(user)
			recentpump = 1
			spawn(10)
				recentpump = 0
			return
		else if(!gun_energy && istype(magazine_module, /obj/item/ammo_box/magazine/internal/cylinder))
			var/num_unloaded = 0
			while (get_ammo() > 0)
				var/obj/item/ammo_casing/CB
				CB = magazine.get_round(0)
				chambered = null
				CB.loc = get_turf(src.loc)
				CB.SpinAnimation(10, 1)
				CB.update_icon()
				num_unloaded++
			for(var/obj/item/ammo_casing/i in contents)
				i.loc = get_turf(src.loc)
				i.SpinAnimation(10, 1)
				i.update_icon()
			if (num_unloaded)
				to_chat(user, "<span class = 'notice'>You unload [num_unloaded] shell\s from [src].</span>")
			else
				to_chat(user, "<span class='notice'>[src] is empty.</span>")
		else if(!gun_energy && istype(magazine_module, MAGAZINE_INTERNAL))
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			chambered = null
			CB.loc = get_turf(src.loc)
			CB.SpinAnimation(10, 1)
			CB.update_icon()
			to_chat(user, "<span class = 'notice'>You unload shell from [src].</span>")
		else if(gun_energy)
			select_fire(user)
			return
		else
			update_icon()
			return FALSE
		update_icon()
		return FALSE

/obj/item/weapon/gun/projectile/modulargun/proc/pump(mob/M)
	if(collected)
		playsound(M, pick('sound/weapons/guns/shotgun_pump1.ogg', 'sound/weapons/guns/shotgun_pump2.ogg', 'sound/weapons/guns/shotgun_pump3.ogg'), VOL_EFFECTS_MASTER, null, FALSE)
		pumped = 0
		if(chambered)//We have a shell in the chamber
			chambered.loc = get_turf(src.loc)//Eject casing
			chambered.SpinAnimation(5, 1)
			chambered = null
		if(!magazine.ammo_count())	return 0
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC
		update_icon()	//I.E. fix the desc
		return 1

/obj/item/weapon/gun/projectile/modulargun/proc/select_fire(mob/living/user)
	if(collected)
		select++
		if (select > ammo_type.len)
			select = 1
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		fire_sound = shot.fire_sound
		if (shot.select_name)
			to_chat(user, "\red [src] is now set to [shot.select_name].")
		update_icon()
		return

/obj/item/weapon/gun/projectile/modulargun/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(collected)
		if(gun_energy)
			newshot()
		if(chambered)
			if(chambered.BB.damage != 0)
				chambered.BB.damage -= (lessdamage * (pellets + 1))/0.7
				if(chambered.BB.damage < 0)
					chambered.BB.damage = 0
			chambered.BB.dispersion -= lessdispersion
			chambered.pellets = pellets
			if(chambered.BB.dispersion < 0)
				chambered.BB.dispersion = 0
			if(chambered.BB.damage < 0)
				chambered.BB.damage = 0
		..()

/obj/item/weapon/gun/projectile/modulargun/can_fire()
	if(collected)
		if(gun_energy)
			newshot()
		if(chambered && chambered.BB)
			return TRUE

/obj/item/weapon/gun/projectile/modulargun/proc/newshot()
	if(collected)
		if (!ammo_type || !power_supply)
			return
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		if (power_supply.charge < shot.e_cost)
			return
		chambered = shot
		chambered.newshot()
		return

/obj/item/weapon/gun/projectile/modulargun/process_chamber(var/eject_casing = TRUE, var/empty_chamber = TRUE, var/no_casing = FALSE)
	if(collected)
		if(gun_energy)
			if (chambered) // incase its out of energy - since then this will be null.
				var/obj/item/ammo_casing/energy/shot = chambered
				power_supply.use(shot.e_cost * (pellets + 1))
			chambered = null
		else
			if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
				last_fired += pick(20,40,60)
				return
			var/obj/item/ammo_casing/AC = chambered //Find chambered round
			if(isnull(AC) || !istype(AC))
				chamber_round()
				return
			if(eject_casing && caliber != "energy" && !istype(magazine_module, /obj/item/ammo_box/magazine/internal/cylinder))
				AC.loc = get_turf(src.loc) //Eject casing onto ground.
				AC.SpinAnimation(10, 1) //next gen special effects
				spawn(3) //next gen sound effects
					playsound(src, 'sound/weapons/guns/shell_drop.ogg', VOL_EFFECTS_MASTER, 25)

			if(empty_chamber)
				chambered = null
			if(no_casing)
				qdel(AC)
			chamber_round()
		return

/obj/item/weapon/gun/projectile/modulargun/chamber_round()
	if(collected)
		if(!gun_energy)
			if (chambered || !magazine)
				return
			else if (magazine.ammo_count())
				chambered = magazine.get_round()
				chambered.loc = src
				if(chambered.BB)
					if(chambered.reagents && chambered.BB.reagents)
						var/datum/reagents/casting_reagents = chambered.reagents
						casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
						casting_reagents.delete()
		return

/obj/item/weapon/gun/projectile/modulargun/update_icon()
	if(collected)
		if(charge_indicator)
			overlays -= "[icon_state][ratio]"
			if(power_supply.maxcharge)
				ratio = power_supply.charge / power_supply.maxcharge
				ratio = ceil(ratio * 4) * 25
				overlays += "[icon_state][ratio]"
			return

/obj/item/weapon/gun/projectile/modulargun/emp_act(severity)
	if(gun_energy)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
		..()

/obj/item/weapon/gun/projectile/modulargun/proc/change_stat(obj/item/modul1, var/attach, mob/user = null)
	if(istype(modul1, MODULAR))
		var/obj/item/modular/modul = modul1
		if(attach)
			lessdamage += modul.lessdamage
			lessdispersion += modul.lessdispersion
			lessfiredelay += modul.lessfiredelay
			lessrecoil += modul.lessrecoil
			size += modul.size
			if(istype(modul, MODULAR))
				if(modul.icon_overlay)
					overlays += modul.icon_overlay
		else
			lessdamage -= modul.lessdamage
			lessdispersion -= modul.lessdispersion
			lessfiredelay -= modul.lessfiredelay
			lessrecoil -= modul.lessrecoil
			size -= modul.size
			if(istype(modul, MODULAR))
				if(modul.icon_overlay)
					overlays -= modul.icon_overlay

	if(istype(modul1, LENS))
		var/obj/item/ammo_casing/energy/modul = modul1
		if(attach)
			lessdamage += modul.lessdamage
			lessdispersion += modul.lessdispersion
			lessfiredelay += modul.lessfiredelay
			lessrecoil += modul.lessrecoil
			size += modul.size
		else
			lessdamage -= modul.lessdamage
			lessdispersion -= modul.lessdispersion
			lessfiredelay -= modul.lessfiredelay
			lessrecoil -= modul.lessrecoil
			size -= modul.size


	if(istype(modul1, MAGAZINE_CELL))
		var/obj/item/weapon/stock_parts/cell/modul = modul1
		if(attach)
			lessdamage += modul.lessdamage
			lessdispersion += modul.lessdispersion
			lessfiredelay += modul.lessfiredelay
			lessrecoil += modul.lessrecoil
			size += modul.size
		else
			lessdamage -= modul.lessdamage
			lessdispersion -= modul.lessdispersion
			lessfiredelay -= modul.lessfiredelay
			lessrecoil -= modul.lessrecoil
			size -= modul.size

	if(istype(modul1, MAGAZINE_EXTERNAL))
		var/obj/item/ammo_box/magazine/modul = modul1
		if(attach)
			lessdamage += modul.lessdamage
			lessdispersion += modul.lessdispersion
			lessfiredelay += modul.lessfiredelay
			lessrecoil += modul.lessrecoil
			size += modul.size
		else
			lessdamage -= modul.lessdamage
			lessdispersion -= modul.lessdispersion
			lessfiredelay -= modul.lessfiredelay
			lessrecoil -= modul.lessrecoil
			size -= modul.size

	size_value()
	update_icon()
/obj/item/weapon/gun/projectile/modulargun/proc/core_attach(obj/item/device/assembly/signaler/anomaly/modul, var/attach, mob/user = null)
	if(attach)
		if(gun_energy && power_supply)
			if((accessory_type.len == 0) || !(is_type_in_list(modul, accessory_type)))
				size += modul.size
				if(user != null)
					user.drop_item()
					modul.loc = src
				core = modul
				accessory.Add(modul)
				accessory_type.Add(modul.type)
				if(modul.icon_overlay)
					overlays += modul.icon_overlay
				START_PROCESSING(SSobj, src)
				if(user != null)
					to_chat(user, "<span class='notice'>Kernel installed.</span>")
			else
				if(user != null)
					to_chat(user, "<span class='notice'>Module already installed</span>")
		else
			if(user != null)
				to_chat(user, "<span class='notice'>The weapon does not have a built-in battery.</span>")
	else
		size -= modul.size
		core = null
		accessory.Remove(modul)
		accessory_type.Remove(modul.type)
		modul.loc = get_turf(src.loc)
		if(modul.icon_overlay)
			overlays -= modul.icon_overlay
		STOP_PROCESSING(SSobj, src)
		update_icon()
		to_chat(user, "<span class='notice'>Core removed.</span>")

/obj/item/weapon/gun/projectile/modulargun/proc/accessory_attach(obj/item/modular/accessory/modul, var/attach, mob/user = null)
	if(attach)
		if((accessory_type.len == 0) || !(is_type_in_list(modul, accessory_type)))
			if(is_type_in_list(barrel, modul.barrel_size) && gun_type in modul.gun_type)
				if(accessory.len < max_accessory)
					var/conflict = FALSE
					var/list/check = list() + contents + accessory
					for(var/i in check)
						if(is_type_in_list(i, modul.conflicts))
							conflict = TRUE
						if(is_type_in_list(i, modul.conflicts))
							conflict = TRUE
					if(!conflict)
						accessory.Add(modul)
						accessory_type.Add(modul.type)
						change_stat(modul, TRUE, user)
						if(user != null)
							user.drop_item()
							modul.loc = src
						modul.fixation = TRUE
						modul.parent = src
						modul.activate(user)
						update_icon()
						size_value()
						if(user != null)
							to_chat(user, "<span class='notice'>Accessory installed</span>")
						return TRUE
					else
						if(user != null)
							to_chat(user, "<span class='notice'>The module conflicts with another module.</span>")
				else
					if(user != null)
						to_chat(user, "<span class='notice'>Maximum modules reached</span>")
			else
				if(user != null)
					to_chat(user, "<span class='notice'>The module does not fit the barrel</span>")
		else
			if(user != null)
				to_chat(user, "<span class='notice'>Module already installed</span>")

		return FALSE

	else
		accessory.Remove(modul)
		accessory_type.Remove(modul.type)
		change_stat(modul, FALSE, user)
		modul.deactivate(user)
		modul.parent = null
		modul.fixation = FALSE
		modul.loc = get_turf(src.loc)
		update_icon()
		size_value(user)
		return TRUE

/obj/item/weapon/gun/projectile/modulargun/proc/chamber_attach(obj/item/modular/chamber/modul, var/attach, mob/user = null)
	if(attach)
		chamber = modul
		caliber = chamber.caliber
		gun_type = chamber.gun_type
		gun_energy = chamber.gun_energy
		multi_type = chamber.multi_type
		type_cap = chamber.type_cap
		pellets = chamber.pellets
		charge_indicator = chamber.charge_indicator
		icon = 'code/modules/projectiles/modules/modular.dmi'
		icon_state = chamber.icon_overlay
		change_stat(chamber, TRUE, user)
		if(user != null)
			user.drop_item()
			modul.loc = src
		return TRUE
	else
		change_stat(chamber, FALSE, user)
		modul.loc = get_turf(src.loc)
		for(var/obj/item/i in contents)
			attach(i, FALSE, user)

		for(var/obj/item/i in contents)
			i.loc = get_turf(src.loc)
			contents.Remove(i)

		contents = null

		chambered = null
		chamber = null
		caliber = null
		gun_type = null
		gun_energy = null
		multi_type = null
		type_cap = null
		pellets = null
		inited = FALSE
		ammo_type = list()

		icon_state = "357"
		icon = 'icons/obj/ammo.dmi'
		update_icon()
		if(user != null)
			to_chat(user, "<span class='notice'>The chamber is taken out</span>")
		return TRUE

/obj/item/weapon/gun/projectile/modulargun/proc/barrel_attach(obj/item/modular/barrel/modul, var/attach, mob/user = null)
	if(attach)
		if(chamber && !barrel)
			barrel = modul
			change_stat(modul, TRUE, user)
			if(user != null)
				user.drop_item()
				modul.loc = src
			return TRUE
		return FALSE
	else
		change_stat(modul, FALSE, user)
		modul.loc = get_turf(src.loc)
		barrel = null
		contents.Remove(modul)
		for(var/obj/item/i in accessory)
			if(i in contents)
				contents.Remove(i)
			if(i in user.contents)
				user.contents.Remove(i)
			attach(i, FALSE, user)
		if(user != null)
			to_chat(user, "<span class='notice'>The barrel is taken out</span>")
		return TRUE

/obj/item/weapon/gun/projectile/modulargun/proc/grip_attach(obj/item/modular/grip/modul, var/attach, mob/user = null)
	if(attach)
		if(chamber && !grip)
			grip = modul
			change_stat(modul, TRUE, user)
			if(user != null)
				user.drop_item()
				modul.loc = src
			return TRUE
		return FALSE
	else
		change_stat(modul, FALSE, user)
		modul.loc = get_turf(src.loc)
		grip = null
		return TRUE

/obj/item/weapon/gun/projectile/modulargun/proc/lens_attach(obj/item/ammo_casing/energy/modul, var/attach, mob/user = null)
	if(attach)
		if(modul.caliber == caliber)
			if(multi_type && ammo_type.len < type_cap)
				ammo_type += modul
				lens.Add(modul)
				change_stat(modul, TRUE, user)
				if(user != null)
					user.drop_item()
					modul.loc = src
				return TRUE
			else if(!multi_type && ammo_type.len == 0)
				ammo_type += modul
				lens.Add(modul)
				change_stat(modul, TRUE, user)
				if(user != null)
					user.drop_item()
					modul.loc = src
				return TRUE
		return FALSE
	else
		lens.Remove(modul)
		ammo_type.Remove(modul)
		contents.Remove(modul)

		change_stat(modul, FALSE, user)
		modul.loc = get_turf(src.loc)
		inited = FALSE
		if(user != null)
			to_chat(user, "<span class='notice'>The lens is taken out</span>")
		return TRUE

/obj/item/weapon/gun/projectile/modulargun/proc/magazine_attach(obj/item/modul1, var/attach, mob/user = null)
	if(attach)
		if(istype(modul1, /obj/item/weapon/stock_parts/cell))
			var/obj/item/weapon/stock_parts/cell/modul = modul1
			magazine_module = modul
			magazine_eject = FALSE
			power_supply = magazine_module
			cell_type = power_supply.type
			overlays += "magazine_charge"
			change_stat(modul, TRUE, user)
			if(user != null)
				user.drop_item()
				modul.loc = src
			return TRUE

		else if(istype(modul1, /obj/item/ammo_box/magazine/internal))
			var/obj/item/ammo_box/magazine/internal/modul = modul1
			magazine_module = modul
			magazine_eject = FALSE
			mag_type = magazine_module.type
			magazine = magazine_module
			overlays += "magazine_internal"
			change_stat(modul, TRUE, user)
			if(user != null)
				user.drop_item()
				modul.loc = src
			return TRUE

		else
			if(istype(modul1, /obj/item/ammo_box/magazine))
				var/obj/item/ammo_box/magazine/modul = modul1
				magazine_module = modul
				magazine_eject = TRUE
				mag_type = magazine_module.type
				magazine = magazine_module
				overlays += "magazine_external"
				change_stat(modul, TRUE, user)
				if(user != null)
					user.drop_item()
					modul.loc = src
				return TRUE
		return FALSE
	else
		if(istype(modul1, MAGAZINE_CELL))
			var/obj/item/weapon/stock_parts/cell/modul = modul1
			change_stat(modul, FALSE, user)
			modul.loc = get_turf(src.loc)
			magazine_eject = null
			magazine_module = null
			power_supply = null
			cell_type = null
			modul.maxcharge = modul.start_maxcharge
			overlays -= "magazine_charge"
			if(user != null)
				to_chat(user, "<span class='notice'>The cell is taken out</span>")
			return TRUE

		if(istype(modul1, MAGAZINE_EXTERNAL))
			change_stat(modul1, FALSE, user)
			modul1.loc = get_turf(src.loc)
			if(magazine)
				if(istype(magazine_module, MAGAZINE_INTERNAL))
					overlays -= "magazine_internal"
				else
					overlays -= "magazine_external"
				magazine_eject = null
				magazine_module = null
				mag_type = null
				mag_type2 = null
				magazine = null
				if(user != null)
					to_chat(user, "<span class='notice'>The magazine is taken out</span>")
				return TRUE
			else
				if(istype(magazine_module, MAGAZINE_INTERNAL))
					overlays -= "magazine_internal"
				else
					overlays -= "magazine_external"
				magazine_eject = null
				magazine_module = null
				mag_type = null
				mag_type2 = null
				magazine = null
				if(user != null)
					to_chat(user, "<span class='notice'>The magazine is taken out</span>")
				return TRUE
		return FALSE

/obj/item/weapon/gun/projectile/modulargun/attack_hand(mob/user)
	..()
	for(var/obj/item/modular/accessory/i in accessory)
		if(usr.get_active_hand() == src)
			i.activate(user)

/obj/item/weapon/gun/projectile/modulargun/dropped(mob/user)
	..()
	for(var/obj/item/modular/accessory/i in accessory)
		i.deactivate(user)




