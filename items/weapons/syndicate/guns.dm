/obj/item/weapon/gun/projectile/revolver/syndie
	name = "revolver"
	desc = "A powerful revolver, very popular among mercenaries and pirates. Uses .357 ammo"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "synd_revolver"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder

/obj/item/weapon/gun/projectile/automatic/borg
	name = "Robot SMG"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "borg_smg"
	mag_type = /obj/item/ammo_box/magazine/borg45

/obj/item/weapon/gun/projectile/automatic/borg/update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/borg/attack_self(mob/user as mob)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		magazine.update_icon()
		magazine = null
		user << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
	else
		user << "<span class='notice'>There's no magazine in \the [src].</span>"
	return



/obj/item/ammo_box/magazine/borg45
	name = "magazine (.45)"
	icon_state = "a762"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 40

/obj/item/ammo_box/magazine/borg45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/borg45/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/gun/projectile/automatic/borg))
		var/obj/item/weapon/gun/projectile/automatic/borg/SMG = A
		if (!SMG.magazine)
			SMG.magazine = src
			SMG.magazine.loc = SMG
			user << "<span class='notice'>You load a new magazine into \the [SMG].</span>"
			SMG.chamber_round()
			A.update_icon()
			update_icon()
			return 1
		else if (SMG.magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	return 0
//ƒ–Œ¡Œ¬»  Õﬁ ≈–Œ¬
/obj/item/weapon/gun/projectile/automatic/bulldog
	name = "V15 Bulldog shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors. Compatible only with specialized magazines."
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	tc_custom = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = 3.0
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/Gunshot.ogg'

/obj/item/weapon/gun/projectile/automatic/bulldog/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/bulldog/proc/update_magazine()
	if(magazine)
		src.overlays = 0
		overlays += "[magazine.icon_state]_o"
		return

/obj/item/weapon/gun/projectile/automatic/bulldog/update_icon()
	src.overlays = 0
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/bulldog/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return
//Ã¿√¿«»Õ€   ¡”À‹ƒŒ√”//
/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot)"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "m12gb"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[Ceiling(ammo_count(0)/8)*8]"


/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g stun slug)"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/incendiary
	name = "shotgun magazine (12g incendiary)"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "m12gf"
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

//¬»Õ“Œ¬ ¿ Õﬁ ≈–Œ¬
/obj/item/weapon/gun/projectile/automatic/a28
	name = "A28 assault rifle"
	desc = ""
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	tc_custom = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "a28"
	item_state = "a28"
	w_class = 3.0
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/Gunshot.ogg'

/obj/item/weapon/gun/projectile/automatic/a28/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/a28/proc/update_magazine()
	if(magazine)
		src.overlays = 0
		overlays += "[magazine.icon_state]-o"
		return

/obj/item/weapon/gun/projectile/automatic/a28/update_icon()
	src.overlays = 0
	update_magazine()
	icon_state = "a28[chambered ? "" : "-e"]"
	return

//œ¿“–ŒÕ€ » Ã¿√¿«»Õ€   ¿28

/obj/item/ammo_casing/a556
	desc = "A 5.56mm bullet casing."
	caliber = "5.56mm"
	projectile_type = /obj/item/projectile/bullet/rifle2

/obj/item/ammo_casing/a556i
	desc = "A 5.56mm incendiary bullet casing."
	caliber = "5.56mm"
	projectile_type = /obj/item/projectile/bullet/incendiary

/obj/item/ammo_box/magazine/m556
	name = "A28 magazine (5.56mm)"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "556mm"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "5.56mm"
	max_ammo = 30

/obj/item/ammo_box/magazine/m556/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[Ceiling(ammo_count(0)/30)*30]"

/obj/item/ammo_box/magazine/m556/incendiary
	name = "A28 magazine (5.56mm incendiary)"
	ammo_type = /obj/item/ammo_casing/a556i
	icon_state = "556imm"