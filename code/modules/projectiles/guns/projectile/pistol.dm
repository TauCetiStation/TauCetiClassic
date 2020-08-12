/obj/item/weapon/gun/projectile/automatic/silenced
	name = "silenced pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	w_class = ITEM_SIZE_NORMAL
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/sm45
	fire_sound = 'sound/weapons/guns/gunshot_silencer.ogg'
	can_be_holstered = TRUE

/obj/item/weapon/gun/projectile/glock
	name = "G17"
	desc = "Semi-automatic service pistol of 9x19mm cal. Designed for professionals."
	icon_state = "9mm_glock"
	item_state = "9mm_glock"
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/m9mm_2/rubber
	mag_type2 = /obj/item/ammo_box/magazine/m9mm_2
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
	can_be_holstered = TRUE
	var/mag = null

/obj/item/weapon/gun/projectile/glock/atom_init()
	. = ..()
	mag = image('icons/obj/gun.dmi', "mag")
	add_overlay(mag)

/obj/item/weapon/gun/projectile/glock/spec
	name = "G17 GEN3"
	icon_state = "9mm_glock_spec"
	item_state = "9mm_glock_spec"

/obj/item/weapon/gun/projectile/glock/update_icon(load = 0)
	..()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/glock/attack_self(mob/user)
	cut_overlay(mag)
	..()

/obj/item/weapon/gun/projectile/glock/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = I
		if((!magazine && (istype(AM, mag_type) || istype(AM, mag_type2))))
			add_overlay(mag)
	return ..()

/obj/item/weapon/gun/projectile/automatic/silenced/update_icon()
	..()
	icon_state = "[initial(icon_state)]"
	return

/obj/item/weapon/gun/projectile/automatic/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo."
	icon_state = "deagle"
	item_state = "deagle"
	force = 14.0
	mag_type = /obj/item/ammo_box/magazine/m50
	can_be_holstered = TRUE
	fire_sound = 'sound/weapons/guns/gunshot_heavy.ogg'

/obj/item/weapon/gun/projectile/automatic/deagle/afterattack(atom/target, mob/user, proximity, params)
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/deagle/update_icon(load = 0)
	..()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds."
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/Explosion1.ogg'
	origin_tech = "combat=3"
	mag_type = /obj/item/ammo_box/magazine/m75

/obj/item/weapon/gun/projectile/automatic/gyropistol/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/guns/empty_alarm.ogg', VOL_EFFECTS_MASTER, 40)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol
	name = "Stechkin pistol"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon_state = "pistol"
	w_class = ITEM_SIZE_SMALL
	silenced = 0
	origin_tech = "combat=2;materials=2;syndicate=2"
	can_be_holstered = TRUE
	mag_type = /obj/item/ammo_box/magazine/m9mm

/obj/item/weapon/gun/projectile/automatic/pistol/attack_hand(mob/user)
	if(loc == user)
		if(silenced)
			silencer_attack_hand(user)
	..()

/obj/item/weapon/gun/projectile/automatic/pistol/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/silencer))
		silencer_attackby(I, user)
		return
	return ..()

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][silenced ? "-silencer" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/colt1911
	desc = "A cheap Martian knock-off of a Colt M1911. Uses less-than-lethal .45 rounds."
	name = "Colt M1911"
	icon_state = "colt"
	item_state = "colt"
	w_class = ITEM_SIZE_SMALL
	mag_type = /obj/item/ammo_box/magazine/c45r
	mag_type2 = /obj/item/ammo_box/magazine/c45m
	can_be_holstered = TRUE
	fire_sound = 'sound/weapons/guns/gunshot_colt1911.ogg'

/obj/item/weapon/gun/projectile/automatic/colt1911/afterattack(atom/target, mob/user, proximity, params)
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/colt1911/update_icon(load = 0)
	..()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/sec_pistol
	name = "pistol"
	desc = "AT-7 .45 caliber pistol."
	icon_state = "at7"
	fire_sound = 'sound/weapons/guns/gunshot_at7.wav'
	mag_type = /obj/item/ammo_box/magazine/at7_45

/obj/item/weapon/gun/projectile/sec_pistol/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/sec_pistol/proc/update_magazine()
	if(magazine)
		cut_overlays()
		add_overlay(image('icons/obj/gun.dmi', "at7-mag"))
		return

/obj/item/weapon/gun/projectile/sec_pistol/update_icon(load = 0)
	cut_overlays()
	update_magazine()
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return

/obj/item/weapon/gun/projectile/sec_pistol/acm38
	name = "pistol"
	desc = "Seegert ACM38 pistol - when you need be TACTICOOL."
	icon_state = "acm38"
	item_state = "colt"
	fire_sound = 'sound/weapons/guns/gunshot_acm38.ogg'
	mag_type = /obj/item/ammo_box/magazine/acm38_38

/obj/item/weapon/gun/projectile/sec_pistol/update_icon(load = 0)
	if(load)
		icon_state = "[initial(icon_state)]"
		return
	icon_state = "[initial(icon_state)][(!chambered && !get_ammo()) ? "-e" : ""]"
	return
