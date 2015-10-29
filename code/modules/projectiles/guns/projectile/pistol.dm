/obj/item/weapon/gun/projectile/automatic/silenced
	name = "silenced pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon = 'icons/obj/gun.dmi'
	icon_state = "silenced_pistol"
	w_class = 3.0
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/sm45
	fire_sound = 'tauceti/sounds/weapon/Gunshot_silenced.ogg'

/obj/item/weapon/gun/projectile/sigi
	name = "\improper pistol"
	desc = "A W&J Company designed SIGI p250, found pretty much everywhere humans are. Looks like SIG 250, but it's not. Uses 9mm rounds."
	icon_state = "sigi250"
	item_state = "sigi250"
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/m9mmr_2
	var/mag_type2 = /obj/item/ammo_box/magazine/m9mm_2
	fire_sound = 'sound/weapons/Gunshot.ogg'

	var/mag = null

/obj/item/weapon/gun/projectile/sigi/New()
	..()
	mag = image('icons/obj/gun.dmi', "mag")
	overlays += mag
	return

/obj/item/weapon/gun/projectile/sigi/spec
	name = "\improper pistol"
	desc = "A W&J Company designed Special SIGI p250, this one has a military coloring. Looks like SIG 250, but it's not. Uses 9mm rounds."
	icon_state = "sigi250special"
	item_state = "sigi250special"

/obj/item/weapon/gun/projectile/sigi/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/sigi/update_icon(var/load = 0)
	..()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/sigi/attack_self(mob/user as mob)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		overlays -= mag
		user << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
		playsound(src.loc, 'tauceti/sounds/weapon/pistol_reload.ogg', 50, 1, 1)
	else
		user << "<span class='notice'>There's no magazine in \the [src].</span>"
	return

/obj/item/weapon/gun/projectile/sigi/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if ((!magazine && istype(AM, mag_type) || istype(AM, mag_type2)))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			overlays += mag
			user << "<span class='notice'>You load a new magazine into \the [src].</span>"
			chamber_round()
			A.update_icon()
			update_icon()
			playsound(src.loc, 'tauceti/sounds/weapon/pistol_reload.ogg', 50, 1, 1)
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	return 0

/obj/item/weapon/gun/projectile/automatic/silenced/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/silenced/update_icon()
	..()
	icon_state = "[initial(icon_state)]"
	return

/obj/item/weapon/gun/projectile/automatic/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo"
	icon = 'icons/obj/gun.dmi'
	icon_state = "deagle"
	item_state = "deagle"
	force = 14.0
	mag_type = /obj/item/ammo_box/magazine/m50
	fire_sound = 'sound/weapons/guns/deagle_shot.ogg'

/obj/item/weapon/gun/projectile/automatic/deagle/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/deagle/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/deagle/update_icon(var/load = 0)
	..()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/deagle/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && istype(AM, mag_type))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			user << "<span class='notice'>You load a new magazine into \the [src].</span>"
			chamber_round()
			A.update_icon()
			update_icon(1)
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	return 0

/obj/item/weapon/gun/projectile/automatic/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon = 'icons/obj/gun.dmi'
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/Explosion1.ogg'
	origin_tech = "combat=3"
	mag_type = /obj/item/ammo_box/magazine/m75

/obj/item/weapon/gun/projectile/automatic/gyropistol/process_chamber(var/eject_casing = 0, var/empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/gyropistol/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol
	name = "\improper Stechkin pistol"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon = 'tauceti/icons/obj/guns.dmi'
	icon_state = "pistol"
	w_class = 2
	silenced = 0
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m9mm

/obj/item/weapon/gun/projectile/automatic/pistol/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/pistol/attack_hand(mob/user as mob)
	if(loc == user)
		if(silenced)
			silencer_attack_hand(user)
	..()

/obj/item/weapon/gun/projectile/automatic/pistol/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/silencer))
		silencer_attackby(I,user)
	..()

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][silenced ? "-silencer" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/colt1911
	desc = "A cheap Martian knock-off of a Colt M1911. Uses less-than-lethal .45 rounds."
	name = "\improper Colt M1911"
	icon = 'icons/obj/gun.dmi'
	icon_state = "colt"
	item_state = "colt"
	w_class = 2
	mag_type = /obj/item/ammo_box/magazine/c45r
	var/mag_type2 = /obj/item/ammo_box/magazine/c45m
	fire_sound = 'sound/weapons/guns/colt1911_shot.ogg'

/obj/item/weapon/gun/projectile/automatic/colt1911/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/colt1911/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/colt1911/update_icon(var/load = 0)
	..()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/colt1911/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && (istype(AM, mag_type) || istype(AM, mag_type2)))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			user << "<span class='notice'>You load a new magazine into \the [src].</span>"
			chamber_round()
			A.update_icon()
			update_icon(1)
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	return 0