/obj/item/weapon/gun/projectile/automatic/a28/nonlethal
	name = "A28 assault rifle NL"
	icon_state = "a28w"
	item_state = "a28w"
	silenced = 1
	mag_type = /obj/item/ammo_box/magazine/m556/nonlethal
	fire_sound = 'sound/weapons/guns/gunshot_silencer.ogg'

/obj/item/weapon/gun/projectile/automatic/silenced/nonlethal
	name = "Silenced pistol NL"
	icon = 'icons/obj/gun.dmi'
	icon_state = "silenced_pistol_nl"
	mag_type = /obj/item/ammo_box/magazine/sm45/nonlethal

/obj/item/ammo_box/magazine/m556/nonlethal
	name = "A28 magazine (.556NL)"
	ammo_type = /obj/item/ammo_casing/a556/nonlethal
	caliber = "5.56mm"
	max_ammo = 30

/obj/item/ammo_box/magazine/sm45/nonlethal
	name = "magazine (.45NL)"
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c45/nonlethal
	caliber = ".45"
	max_ammo = 12

/obj/item/ammo_casing/a556/nonlethal
	desc = "A 5.56mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/weakbullet/nl_rifle

/obj/item/ammo_casing/c45/nonlethal
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/weakbullet/nl_rifle

/obj/item/projectile/bullet/weakbullet/nl_rifle
	stutter = 10
	agony = 55
