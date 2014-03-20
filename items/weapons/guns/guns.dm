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
	icon = 'tauceti/items/weapons/guns/tommy.dmi'
	tc_custom = 'tauceti/items/weapons/guns/tommy.dmi'
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
	icon = 'tauceti/items/weapons/guns/tommy.dmi'
	tc_custom = 'tauceti/items/weapons/guns/tommy.dmi'
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50
