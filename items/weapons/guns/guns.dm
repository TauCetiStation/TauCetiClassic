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
	pumped = 0
	if(chambered)
		chambered.loc = get_turf(src)
		chambered = null
	if(!magazine.ammo_count())	return 0
	var/obj/item/ammo_casing/AC = magazine.get_round()
	chambered = AC
	update_icon()
	return 1  //полностью копипастить ради одного звука?

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

/obj/item/weapon/gun/projectile/revolver/flare
	name = "flare gun"
	desc = "Fires flares"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "flaregun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/flaregun

/obj/item/ammo_box/magazine/internal/cylinder/flaregun
	name = "Flare gun cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/flare
	caliber = "flare"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_casing/flare
	desc = "A flare for flare gun."
	caliber = "flare"
	icon = 'tauceti/items/weapons/guns/antique_guns.dmi'
	icon_state = "flare"
	projectile_type = "/obj/item/projectile/bullet/flare"

/obj/item/projectile/bullet/flare
	name = "flare"
	icon_state= "bolter"
	damage = 5
	luminosity = 8

/obj/item/projectile/bullet/flare/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/ammo_casing/c38m
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/midbullet2

/obj/item/ammo_box/c38m
	name = "speed loader (.38)"
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38m
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_box/shotgun
	name = "shotgun shells box"
	icon = 'tauceti/icons/obj/ammo.dmi'
	icon_state = "shotgun_shells"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 20

/obj/item/weapon/gun/projectile/automatic/colt1911/dungeon
	desc = "A single-action, semi-automatic, magazine-fed, recoil-operated pistol chambered for the .45 ACP cartridge."
	name = "\improper Colt M1911"
	mag_type = /obj/item/ammo_box/magazine/c45m
	mag_type2 = /obj/item/ammo_box/magazine/c45r

/obj/item/weapon/gun/projectile/revolver/detective/dungeon
	desc = "A a six-shot double-action revolver."
	name = "Smith & Wesson Model 10"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/dungeon

/obj/item/ammo_box/magazine/internal/cylinder/rev38/dungeon
	name = "d-tiv revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/c38m
	caliber = "38"
	max_ammo = 6

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/dualshot/dungeon

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off
	icon_state = "sawnshotgun"
	w_class = 3.0
	item_state = "gun"
	slot_flags = SLOT_BELT
	name = "sawn-off shotgun"
	desc = "Omar's coming!"

/obj/item/ammo_box/magazine/internal/cylinder/dualshot/dungeon
	name = "double-barrel shotgun internal magazine"
	desc = "This doesn't even exist"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/weapon/gun/projectile/shotgun/dungeon
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dungeon

/obj/item/ammo_box/magazine/internal/shot/dungeon
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 5
