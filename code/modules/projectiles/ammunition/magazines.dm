////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(countempties = 1)
	if (!countempties)
		var/boolets = 0
		for (var/i = 1, i <= stored_ammo.len, i++)
			var/obj/item/ammo_casing/bullet = stored_ammo[i]
			if (bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "russian revolver cylinder"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rus357/atom_init()
	. = ..()
	stored_ammo += new ammo_type(src)

/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "d-tiv revolver cylinder"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/heavyrifle
	name = "heavysniper internal magazine"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/a145
	caliber = "14.5mm"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/m79
	name = "m79 grenade launcher internal magazine"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/r4046
	caliber = "40x46"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/shotcom
	name = "combat shotgun internal magazine"
	desc = "Oh god, this shouldn't be here!"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8
	multiload = 0

/obj/item/ammo_box/magazine/internal/shotcom/nonlethal
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/internal/cylinder/dualshot
	name = "double-barrel shotgun internal magazine"
	desc = "This doesn't even exist!"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 2
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rocket
	name = "bazooka internal magazine"
	desc = "This doesn't even exist!"
	ammo_type = /obj/item/ammo_casing/caseless/rocket
	caliber = "rocket"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rev45
	name = "Colt revolver cylinder"
	desc = "Oh god, this shouldn't be here."
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/flaregun
	name = "Flare gun cylinder"
	desc = "Oh god, this shouldn't be here."
	ammo_type = /obj/item/ammo_casing/flare
	caliber = "flare"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rev38/dungeon
	name = "d-tiv revolver cylinder"
	desc = "Oh god, this shouldn't be here."
	ammo_type = /obj/item/ammo_casing/c38m
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/dualshot/dungeon
	name = "double-barrel shotgun internal magazine"
	desc = "This doesn't even exist."
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/dungeon
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 5

///////////EXTERNAL MAGAZINES////////////////
/obj/item/ammo_box/magazine/m9mm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m9mm_2
	name = "magazine (9mm)"
	icon_state = "9mm_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 12

/obj/item/ammo_box/magazine/m9mm_2/rubber
	name = "magazine (9mm rubber)"
	icon_state = "9mmr_mag"
	ammo_type = /obj/item/ammo_casing/c9mmr
	caliber = "9mm"

/obj/item/ammo_box/magazine/m9mm_2/update_icon()
	..()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/magazine/msmg9mm
	name = "SMG magazine (9mm)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 18

/obj/item/ammo_box/magazine/msmg9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),3)]"

/obj/item/ammo_box/magazine/m12mm
	name = "magazine (.45)"
	icon_state = "12mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_box/magazine/m12mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/m12mm/hp
	name = "magazine (.45 HP)"
	desc = "Magazine, full of high power submachinegun ammo."
	icon_state = "12mmhp"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/c45hp
	caliber = ".45S"
	max_ammo = 15

/obj/item/ammo_box/magazine/m12mm/hp/update_icon()
	..()
	if(ammo_count() == 1)
		icon_state = "[initial(icon_state)]-1"
	else
		icon_state = "[initial(icon_state)]-[round(ammo_count(),3)]"

/obj/item/ammo_box/magazine/m12mm/hv
	name = "magazine (.45 HV)"
	desc = "Magazine, full of high velocity submachinegun ammo."
	icon_state = "12mmhv"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/c45hv
	caliber = ".45S"
	max_ammo = 15

/obj/item/ammo_box/magazine/m12mm/hv/update_icon()
	..()
	if(ammo_count() == 1)
		icon_state = "[initial(icon_state)]-1"
	else
		icon_state = "[initial(icon_state)]-[round(ammo_count(),3)]"


/obj/item/ammo_box/magazine/m12mm/imp
	name = "magazine (.45 IMP)"
	desc = "Magazine, full of impact submachinegun ammo."
	icon_state = "12mmimp"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/c45imp
	caliber = ".45S"
	max_ammo = 15

/obj/item/ammo_box/magazine/m12mm/imp/update_icon()
	..()
	if(ammo_count() == 1)
		icon_state = "[initial(icon_state)]-1"
	else
		icon_state = "[initial(icon_state)]-[round(ammo_count(),3)]"


/obj/item/ammo_box/magazine/sm45
	name = "magazine (.45)"
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 12

/obj/item/ammo_box/magazine/sm45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/c45m
	name = "magazine (.45)"
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 7

/obj/item/ammo_box/magazine/c45m/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count()]"

/obj/item/ammo_box/magazine/c45r
	name = "magazine (.45 rubber)"
	icon_state = "45r"
	ammo_type = /obj/item/ammo_casing/c45r
	caliber = ".45"
	max_ammo = 7

/obj/item/ammo_box/magazine/c45r/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count()]"

/obj/item/ammo_box/magazine/uzim9mm
	name = "Mac-10 magazine (9mm)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "uzi9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/magazine/uzim45
	name = "Uzi magazine (.45)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "uzi45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 16

/obj/item/ammo_box/magazine/uzim45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "magazine (.50ae)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m75
	name = "magazine (.75)"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = "75"
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m762
	name = "magazine (7.62mm)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 50

/obj/item/ammo_box/magazine/m762/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/chameleon
	name = "magazine (.45)"
	icon_state = "45"
	ammo_type = "/obj/item/ammo_casing/chameleon"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/c5_9mm
	name = "magazine (9mm rubber)"
	icon_state = "c5_mag"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/c9mmr
	caliber = "9mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/c5_9mm/update_icon()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/magazine/c5_9mm/letal
	name = "magazine (9mm)"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/at7_45
	name = "magazine (.45 rubber)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "at7_mag"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/c45r
	caliber = ".45"
	max_ammo = 8

/obj/item/ammo_box/magazine/at7_45/update_icon()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/magazine/at7_45/letal
	name = "magazine (.45)"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45

/obj/item/ammo_box/magazine/l13_38
	name = "magazine (.38 rubber)"
	icon_state = "l13_mag"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 20

/obj/item/ammo_box/magazine/l13_38/update_icon()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/magazine/l13_38/lethal
	name = "magazine (.38)"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c38m

/obj/item/ammo_box/magazine/acm38_38
	name = "magazine (.38 rubber)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "38_mag"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 12

/obj/item/ammo_box/magazine/acm38_38/update_icon()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/magazine/acm38_38/lethal
	name = "magazine (.38)"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c38m

/obj/item/ammo_box/magazine/tommygunm45
	name = "tommy gun drum (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/internal/repeater
	name = "repeater internal magazine"
	desc = "Oh god, this shouldn't be here."
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 8
	multiload = 0

/obj/item/ammo_box/magazine/a3006_clip
	name = ".30-06 ammo clip"
	icon_state = "clip"
	origin_tech = "combat=2"
	caliber = "a3006"
	ammo_type = /obj/item/ammo_casing/a3006
	max_ammo = 5

/obj/item/ammo_box/magazine/a3006_clip/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count()]"

/obj/item/ammo_box/magazine/m3006
	name = "magazine (.30-06)"
	icon_state = "30-06"
	ammo_type = /obj/item/ammo_casing/a3006
	caliber = "a3006"
	multiple_sprites = 2
	max_ammo = 20

/obj/item/ammo_box/magazine/m9pmm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/borg45
	name = "magazine (.45)"
	icon_state = "a762"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 40

/obj/item/ammo_box/magazine/borg45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/borg45/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/gun/projectile/automatic/borg))
		var/obj/item/weapon/gun/projectile/automatic/borg/SMG = I
		if (!SMG.magazine)
			SMG.magazine = src
			SMG.magazine.forceMove(SMG)
			playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You load a new magazine into \the [SMG].</span>")
			SMG.chamber_round()
			I.update_icon()
			update_icon()
			return TRUE

		else if (SMG.magazine)
			to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")
			return

	return ..()

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot)"
	icon_state = "m12gb"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[CEIL(ammo_count(0) / 8) * 8]"


/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g stun slug)"
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/incendiary
	name = "shotgun magazine (12g incendiary)"
	icon_state = "m12gf"
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/magazine/m556
	name = "A28 magazine (5.56mm)"
	icon_state = "556mm"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "5.56mm"
	max_ammo = 30

/obj/item/ammo_box/magazine/m556/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[CEIL(ammo_count(0) / 30) * 30]"

/obj/item/ammo_box/magazine/m556/incendiary
	name = "A28 magazine (5.56mm incendiary)"
	ammo_type = /obj/item/ammo_casing/a556i
	icon_state = "556imm"

/obj/item/ammo_box/magazine/a74mm
	name = "A74 magazine (7.74mm)"
	icon_state = "a74mm"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a74
	caliber = "7.74mm"
	max_ammo = 30

/obj/item/ammo_box/magazine/a74mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[CEIL(ammo_count(0) / 30) * 30]"

/obj/item/ammo_box/magazine/plasma
	name = "plasma weapon battery pack"
	desc = "A special battery case with protection against EM pulse. Uses fast charge method. Has standardized dimensions and can be used with any plasma type gun of this series. Power cell can be replaced."
	icon_state = "plasma_clip"
	origin_tech = "combat=2"
	ammo_type = null // unused, those are inside guns of this type.
	caliber = "plasma"
	max_ammo = 0 // not used with this magazine.

	var/obj/item/weapon/stock_parts/cell/power_supply
	var/cell_type = /obj/item/weapon/stock_parts/cell/super // we balance ammo consumption and amount over this type of battery, because even this battery still requires basic materials to craft.

/obj/item/ammo_box/magazine/plasma/atom_init()
	. = ..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	update_icon()

/obj/item/ammo_box/magazine/plasma/Destroy()
	QDEL_NULL(power_supply)
	return ..()

/obj/item/ammo_box/magazine/plasma/attackby(obj/item/I, mob/user, params)
	if(power_supply && isscrewdriver(I))
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		user.put_in_hands(power_supply)
		power_supply = null
		update_icon()

	else if(istype(I, /obj/item/weapon/stock_parts/cell) && !power_supply && user.drop_from_inventory(I, src))
		playsound(src, 'sound/items/change_drill.ogg', VOL_EFFECTS_MASTER)
		power_supply = I
		update_icon()

	else
		return ..()

/obj/item/ammo_box/magazine/plasma/get_round(keep = FALSE)
	return null

/obj/item/ammo_box/magazine/plasma/proc/get_charge()
	if(!power_supply)
		return 0
	return power_supply.charge

/obj/item/ammo_box/magazine/plasma/proc/has_overcharge()
	return power_supply.charge > PLASMAGUN_OVERCHARGE

/obj/item/ammo_box/magazine/plasma/ammo_count() // we don't use this proc
	return 0

/obj/item/ammo_box/magazine/plasma/examine(mob/user)
	. = ..(user, 1)
	if(.)
		to_chat(user, "<span class='notice'>You see a charge meter, it reads: [power_supply ? round(power_supply.charge * 100 / power_supply.maxcharge) : "nan"]%.</span>")

/obj/item/ammo_box/magazine/plasma/attack_self(mob/user) // check parent proc before adding ..() or removing this one.
	return

/obj/item/ammo_box/magazine/plasma/update_icon()
	if(!power_supply)
		icon_state = "[initial(icon_state)]-0"
		return
	// yes, it stops reporting accurate data for icon if its overflowing with energy till it drops charge under certain amount.
	icon_state = "[initial(icon_state)]-[has_overcharge() ? "oc" : CEIL(power_supply.charge / power_supply.maxcharge * 5) * 20]"

/obj/item/ammo_box/magazine/plasma/emp_act() // just incase if someone adds emp_act in parent.
	return
