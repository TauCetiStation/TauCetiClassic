/obj/item/weapon/gun/projectile/modulargun
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	desc = ""
	name = "The basis of the weapon"
	flags = CONDUCT
	w_class = ITEM_SIZE_NORMAL
	magazine = null
	mag_type = null
	mag_type2 = null
	fire_delay = 10

	var/obj/item/modular/barrel/barrel = null
	var/obj/item/modular/grip/grip = null
	var/obj/item/modular/chambered/chamber = null
	var/obj/item/ammo_box/magazine/magazine1in = null

	var/obj/item/weapon/stock_parts/cell/power_supply = null //What type of power cell this uses
	var/cell_type = /obj/item/weapon/stock_parts/cell
	var/modifystate = FALSE
	var/list/ammo_type
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.

	var/magazine_eject
	var/gun_energy = FALSE
	var/multi_type = FALSE
	var/type_cap = 1

	var/collected = FALSE
	var/size = 0.0
	var/lessdamage = 0.0
	var/lessdispersion = 0.0
	var/lessfiredelay = 0
	var/lessrecoil = 0.0
	var/lessvariance = 0.0
	var/caliber
	var/gun_type
	var/pellets

	var/recentpump = 0 // to prevent spammage
	var/pumped = 0

/obj/item/modular
	icon = 'code/modules/projectiles/modules/modular.dmi'
	flags = CONDUCT
	var/size = 0.0
	var/lessdamage = 0.0
	var/lessdispersion = 0.0
	var/lessfiredelay = 0
	var/lessrecoil = 0.0
	var/gun_type

/obj/item/weapon/gun/projectile/modulargun/proc/initex()
	if(collected)
		if(gun_energy)
			power_supply.give(power_supply.maxcharge)
			var/obj/item/ammo_casing/energy/shot
			for (var/i in 1 to ammo_type.len)
				var/shottype = ammo_type[i]
				shot = new shottype(src)
				ammo_type[i] = shot
			shot = ammo_type[select]
			fire_sound = shot.fire_sound
			update_icon()
		else
			chamber_round()
			update_icon()

/obj/item/weapon/gun/projectile/modulargun/proc/attach(obj/item/modular/modul, var/attach, mob/user)
	if(attach)
		user.drop_item()
		modul.loc = src
		lessdamage += modul.lessdamage
		lessdispersion += modul.lessdispersion
		lessfiredelay += modul.lessfiredelay
		lessrecoil += modul.lessrecoil
		size += modul.size
		overlays += modul.icon_state
	else
		modul.loc = get_turf(src)
		lessdamage -= modul.lessdamage
		lessdispersion -= modul.lessdispersion
		lessfiredelay -= modul.lessfiredelay
		lessrecoil -= modul.lessrecoil
		size -= modul.size
		overlays -= modul.icon_state
	return modul

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
		if (istype(A, /obj/item/ammo_box/magazine) && magazine_eject)
			var/obj/item/ammo_box/magazine/AM = A
			if (!magazine && (istype(AM, mag_type) || (istype(AM, mag_type2) && mag_type != null)) && AM.caliber == caliber)
				user.remove_from_mob(AM)
				magazine = AM
				magazine.loc = src
				playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
				chamber_round()
				A.update_icon()
				update_icon()
				return TRUE
			else if (magazine)
				to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")

	if(!collected)
		if(istype(A, /obj/item/modular/chambered))
			var/obj/item/modular/chambered/modul = A
			chamber = attach(modul, TRUE, user)
			caliber = chamber.caliber
			gun_type = chamber.gun_type
			gun_energy = chamber.gun_energy
			multi_type = chamber.multi_type
			type_cap = chamber.type_cap
			pellets = chamber.pellets
			icon = 'code/modules/projectiles/modules/modular.dmi'
			icon_state = chamber.icon_state
			to_chat(user, "<span class='notice'>Chamber installed \the [src]. Type gun [gun_type]. Caliber [caliber].</span>")

		if(chamber && !barrel && istype(A, /obj/item/modular/barrel))
			var/obj/item/modular/barrel/modul = A
			if(gun_type in modul.gun_type)
				barrel = attach(modul, TRUE, user)
				to_chat(user, "<span class='notice'>Barrel installed \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the type \the [src].</span>")

		if(chamber && !grip && istype(A, /obj/item/modular/grip))
			var/obj/item/modular/grip/modul = A
			if(gun_type in modul.gun_type)
				grip = attach(modul, TRUE, user)
				to_chat(user, "<span class='notice'>Handle installed \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the type \the [src].</span>")

		if(chamber && !power_supply && istype(A, /obj/item/weapon/stock_parts/cell))
			var/obj/item/weapon/stock_parts/cell/modul = A
			if(gun_energy)
				size += modul.size
				user.drop_item()
				modul.loc = src
				magazine_eject = FALSE
				magazine1in = modul
				overlays += "magazine_charge"
				to_chat(user, "<span class='notice'>Battery installed \the [src]. Type internal</span>")

		if(chamber && gun_energy && istype(A, /obj/item/ammo_casing/energy))
			var/obj/item/ammo_casing/energy/modul = A
			if(modul.caliber == caliber)
				if(multi_type && ammo_type.len < type_cap)
					user.drop_item()
					ammo_type += modul.type
					attach(modul, TRUE, user)
					to_chat(user, "<span class='notice'>Crystal installed \the [src]. Type internal</span>")
				else if(!multi_type && ammo_type.len == 0)
					user.drop_item()
					ammo_type += modul.type
					attach(modul, TRUE, user)
					to_chat(user, "<span class='notice'>Crystal installed \the [src]. Type internal</span>")
				else
					to_chat(user, "<span class='notice'>Crystal not installed \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the caliber \the [src].</span>")

		if(chamber && !magazine1in && istype(A, /obj/item/ammo_box/magazine/internal))
			var/obj/item/ammo_box/magazine/internal/modul = A
			if(modul.caliber == caliber)
				user.drop_item()
				modul.loc = src
				magazine1in = modul
				size += modul.size
				magazine_eject = FALSE
				overlays += "magazine_internal"
				to_chat(user, "<span class='notice'>Store installed \the [src]. Type internal</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the caliber \the [src].</span>")

		if(chamber && !magazine1in && istype(A, /obj/item/ammo_box/magazine))
			var/obj/item/ammo_box/magazine/modul = A
			if(modul.caliber == caliber)
				user.drop_item()
				modul.loc = src
				magazine1in = modul
				size += modul.size
				magazine_eject = TRUE
				overlays += "magazine_external"
				to_chat(user, "<span class='notice'>Store installed \the [src]. Type external</span>")
			else
				to_chat(user, "<span class='notice'>The module does not fit the caliber \the [src].</span>")
		if(iswrench(A))
			var/modul1 = input(user, "Pull module", "Changing") in contents
			if(istype(modul1, chamber.type))
				lessdamage = 0.0
				lessdispersion = 0.0
				lessfiredelay = 0
				lessrecoil = 0.0
				size = 0.0
				chamber.loc = get_turf(src)
				chamber = null
				barrel.loc = get_turf(src)
				barrel = null
				grip.loc = get_turf(src)
				grip = null
				magazine_eject = null
				magazine1in.loc = get_turf(src)
				size -= magazine1in.size
				magazine1in = null
				power_supply = null
				ammo_type = list()
				type_cap = 1
				for(var/i in contents)
					var/obj/item/ammo_casing/modul = i
					modul.loc = get_turf(src)
					lessdamage -= modul.lessdamage
					lessdispersion -= modul.lessdispersion
					lessfiredelay -= modul.lessfiredelay
					lessrecoil -= modul.lessrecoil
					size -= modul.size
				overlays.Cut()
				icon_state = "357"
				icon = 'icons/obj/ammo.dmi'

			if(istype(modul1, barrel.type))
				var/obj/item/modular/barrel/modul = modul1
				attach(modul, FALSE, user)
				barrel = null

			if(istype(modul1, grip.type))
				var/obj/item/modular/grip/modul = modul1
				attach(modul, FALSE, user)
				grip = null

			if(istype(modul1, magazine1in.type))
				size -= magazine1in.size
				magazine_eject = null
				magazine1in.loc = get_turf(src)
				magazine1in = null
				if(gun_energy)
					power_supply = null
			if(istype(modul1, /obj/item/ammo_casing))
				var/obj/item/ammo_casing/modul = modul1
				attach(modul, FALSE, user)
				ammo_type -= modul.type



	if(isscrewdriver(A))
		collected = !collected
		if(collected)
			if(chamber && barrel && grip && magazine1in)
				if(size <= 0.4)
					w_class = ITEM_SIZE_SMALL
				if(size > 0.4 && size <= 0.7)
					w_class = ITEM_SIZE_NORMAL
				if(size > 0.7)
					w_class = ITEM_SIZE_LARGE

				if(!gun_energy)
					mag_type = magazine1in.type
					magazine = magazine1in
				else
					power_supply = magazine1in
					cell_type = power_supply.type
					power_supply.charge /= 10
					power_supply.maxcharge /= 10

				if(lessrecoil > 0.5)
					recoil = FALSE
				else
					recoil = TRUE

				fire_delay -= lessfiredelay

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

				initex()
				name = "[weapon_size] weapon [gun_type] [caliber] gun"
				desc = "Assembly completed \the [src]. Weapon Type - [gun_type]. Weapon size - [weapon_size]. Caliber - [caliber]. Type store - [magazine_ejected]."
				to_chat(user, "<span class='notice'>Assembly completed \the [src]. Weapon Type - [gun_type]. Weapon size - [weapon_size]. Caliber - [caliber]. Type store - [magazine_ejected].</span>")
		else
			w_class = ITEM_SIZE_NORMAL
			to_chat(user, "<span class='notice'>Disassembly completed \the [src].")
			name = "The basis of the weapon"
			fire_delay = 10

/obj/item/weapon/gun/projectile/modulargun/attack_self(mob/living/user)
	if(collected)
		if (magazine && src && magazine_eject && !gun_energy)
			magazine.loc = get_turf(src.loc)
			user.put_in_hands(magazine)
			magazine.update_icon()
			magazine = null
			update_icon()
			playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
			return TRUE
		else if (magazine_eject && !gun_energy)
			to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
		else if(!gun_energy && !magazine_eject)
			if(recentpump)
				return
			pump(user)
			recentpump = 1
			spawn(10)
				recentpump = 0
			return
		else if(gun_energy)
			select_fire(user)
			return
		else
			update_icon()
			return FALSE
		update_icon()
		return FALSE

/obj/item/weapon/gun/projectile/modulargun/proc/pump(mob/M)
	playsound(M, pick('sound/weapons/guns/shotgun_pump1.ogg', 'sound/weapons/guns/shotgun_pump2.ogg', 'sound/weapons/guns/shotgun_pump3.ogg'), VOL_EFFECTS_MASTER, null, FALSE)
	pumped = 0
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
	if(!magazine.ammo_count())	return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/modulargun/proc/select_fire(mob/living/user)
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
			chambered.BB.damage -= lessdamage
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
				power_supply.use(shot.e_cost)
			chambered = null
		else
			if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
				last_fired += pick(20,40,60)
				return
			var/obj/item/ammo_casing/AC = chambered //Find chambered round
			if(isnull(AC) || !istype(AC))
				chamber_round()
				return
			if(eject_casing)
				AC.loc = get_turf(src) //Eject casing onto ground.
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

/obj/item/weapon/gun/projectile/modulargun/emp_act(severity)
	if(gun_energy)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
		..()




