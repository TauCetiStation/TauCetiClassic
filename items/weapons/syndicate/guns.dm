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


