/obj/item/weapon/gun/projectile/revolver/syndie
	name = "revolver"
	desc = "A powerful revolver, very popular among mercenaries and pirates. Uses .357 ammo"
	icon = 'tauceti/items/weapons/guns/syndie_revolver.dmi'
	icon_state = "synd_revolver"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "tommy gun"
	desc = "A genuine Chicago Typewriter."
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	tc_custom = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "tommygun"
	item_state = "tommygun"
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'

/obj/item/weapon/gun/projectile/automatic/tommygun/isHandgun()
	return 0

obj/item/ammo_box/magazine/tommygunm45
	name = "tommy gun drum (.45)"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	tc_custom = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/weapon/gun/projectile/shotgun/repeater
	name = "repeater rifle"
	desc = "Winchester Model 1894"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	tc_custom = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "repeater"
	item_state = "repeater"
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/repeater
	w_class = 5
	slot_flags = 0

/obj/item/weapon/gun/projectile/shotgun/repeater/attack_self(mob/living/user)
	if(recentpump)	return
	pump(user)
	recentpump = 1
	spawn(6)
		recentpump = 0
	return

/obj/item/weapon/gun/projectile/shotgun/repeater/pump(mob/M)
	playsound(M, 'tauceti/sounds/weapon/repeater_reload.wav', 60, 0)
	..()

/obj/item/ammo_box/magazine/internal/repeater
	name = "repeater internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 8
	multiload = 0

/obj/item/weapon/gun/projectile/shotgun/bolt_action
	name = "bolt-action rifle"
	desc = "Springfield M1903"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	tc_custom = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "bolt-action"
	item_state = "bolt-action"
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/a3006_clip
	w_class = 5
	slot_flags = 0

/obj/item/weapon/gun/projectile/shotgun/bolt_action/pump(mob/M)
	playsound(M, 'tauceti/sounds/weapon/bolt_reload.ogg', 60, 0)
	pumped = 0
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered = null
	if(magazine && !magazine.ammo_count())
		magazine.loc = get_turf(src.loc)
		magazine.update_icon()
		magazine = null
		return 0
	if(magazine && magazine.ammo_count())
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC
		update_icon()	//I.E. fix the desc
		return 1

/obj/item/weapon/gun/projectile/shotgun/bolt_action/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && istype(AM, mag_type))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			user << "<span class='notice'>You load a new clip into \the [src].</span>"
			chamber_round()
			A.update_icon()
			update_icon()
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a clip in \the [src].</span>"
	return 0

/obj/item/ammo_box/magazine/a3006_clip
	name = ".30-06 ammo clip"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "clip"
	origin_tech = "combat=2"
	caliber = "a3006"
	ammo_type = /obj/item/ammo_casing/a3006
	max_ammo = 5

/obj/item/ammo_box/magazine/a3006_clip/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count()]"

/obj/item/ammo_casing/a3006
	desc = "A .30-06 bullet casing."
	caliber = "a3006"
	projectile_type = "/obj/item/projectile/bullet/midbullet3"

/obj/item/projectile/bullet/midbullet3
	damage = 35

/obj/item/weapon/gun/projectile/automatic/bar
	name = "Browning M1918"
	desc = "Browning Automatic Rifle"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	tc_custom = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "bar"
	item_state = "bar"
	w_class = 5.0
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/m3006
	fire_sound = 'tauceti/sounds/weapon/gunshot3.wav'

/obj/item/ammo_box/magazine/m3006
	name = "magazine (.30-06)"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "30-06"
	ammo_type = /obj/item/ammo_casing/a3006
	caliber = "a3006"
	multiple_sprites = 2
	max_ammo = 20

/obj/item/weapon/gun/projectile/automatic/luger
	name = "Luger P08"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "p08"
	w_class = 2
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m9pmm

/obj/item/weapon/gun/projectile/automatic/luger/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/luger/isHandgun()
	return 1

/obj/item/ammo_box/magazine/m9pmm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/weapon/gun/projectile/revolver/peacemaker
	name = "Colt SAA"
	desc = "A legend of Wild West"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "peacemaker"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45

/obj/item/weapon/gun/projectile/revolver/peacemaker/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/revolver/peacemaker/attack_self(mob/living/user as mob)
	var/num_unloaded = 0
	if (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		user << "<span class = 'notice'>You unload [num_unloaded] shell\s from [src].</span>"
	else
		user << "<span class='notice'>[src] is empty.</span>"

/obj/item/ammo_box/magazine/internal/cylinder/rev45
	name = "Colt revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 6
	multiload = 0