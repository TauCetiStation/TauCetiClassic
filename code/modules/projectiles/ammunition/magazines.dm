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
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m9mmr_2
	name = "magazine (9mm rubber)"
	icon_state = "9mm_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mmr
	caliber = "9mm"
	max_ammo = 8
	multiple_sprites = 2


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
/*
/obj/item/ammo_box/magazine/m10mm
	name = "magazine (10mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = 2 */

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
	icon_state = "[initial(icon_state)]-[ammo_count() ? "7" : "0"]"

/obj/item/ammo_box/magazine/c45r
	name = "magazine (.45 rubber)"
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45r
	caliber = ".45"
	max_ammo = 7

/obj/item/ammo_box/magazine/c45r/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "7" : "0"]"

/obj/item/ammo_box/magazine/uzim9mm
	name = "Mac-10 magazine (9mm)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon()
	..()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

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

/obj/item/ammo_box/magazine/l10mag
	name = "L10-c battery"
	desc = "A special battery with protection from EM pulse."
	icon_state = "l10_clip"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/l10
	caliber = "energy"
	max_ammo = 25

/obj/item/ammo_box/magazine/l10mag/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "<span class='notice'>You see a charge meter, it reads: [round(ammo_count() * 100 / max_ammo)]%.</span>")

/obj/item/ammo_box/magazine/l10mag/attack_self(mob/user)
	return

/obj/item/ammo_box/magazine/l10mag/update_icon()
	icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

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

/obj/item/ammo_box/magazine/borg45/attackby(obj/item/A, mob/user)
	if (istype(A, /obj/item/weapon/gun/projectile/automatic/borg))
		var/obj/item/weapon/gun/projectile/automatic/borg/SMG = A
		if (!SMG.magazine)
			SMG.magazine = src
			SMG.magazine.loc = SMG
			playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', 60, 1)
			to_chat(user, "<span class='notice'>You load a new magazine into \the [SMG].</span>")
			SMG.chamber_round()
			A.update_icon()
			update_icon()
			return 1
		else if (SMG.magazine)
			to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")
	return 0

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot)"
	icon_state = "m12gb"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ceil(ammo_count(0) / 8) * 8]"


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
	icon_state = "[initial(icon_state)]-[ceil(ammo_count(0) / 30) * 30]"

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
	icon_state = "[initial(icon_state)]-[ceil(ammo_count(0) / 30) * 30]"
