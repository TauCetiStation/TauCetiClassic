/datum/event/feature/area/replace/sec_rearmament
	special_area_types = list(/area/station/security/warden, /area/station/security/armoury, /area/station/security/hos, /area/station/security/main, /area/station/security/checkpoint, /area/station/medical/reception)
	replace_types = list(
		/obj/item/weapon/gun,
	)

/datum/event/feature/area/replace/sec_rearmament/bullets
	replace_types = list(
		/obj/item/weapon/gun/energy/taser = /obj/item/weapon/gun/projectile/automatic/glock,
		/obj/item/weapon/gun/plasma = /obj/item/weapon/gun/projectile/revolver/doublebarrel,
		/obj/item/weapon/gun/energy/laser = /obj/item/weapon/gun/projectile/automatic/l13,
		/obj/item/weapon/gun/energy/gun/hos = /obj/item/weapon/gun/projectile/automatic/glock/spec,
		/obj/item/ammo_box/magazine/plasma = /obj/item/ammo_box/shotgun/beanbag,
		/obj/item/weapon/gun/energy/gun = /obj/item/ammo_box/magazine/l13,
	)

/datum/event/feature/area/replace/sec_rearmament/energy
	replace_types = list(
		/obj/item/weapon/gun/energy/taser = /obj/item/weapon/gun/energy/taser/stunrevolver,
		/obj/item/weapon/gun/projectile/automatic/glock = /obj/item/weapon/gun/energy/taser/stunrevolver,
		/obj/item/ammo_box/magazine/glock/rubber = /obj/item/device/radio_grid,
		/obj/item/ammo_box/magazine/glock = /obj/item/weapon/grenade/empgrenade,
		/obj/item/weapon/gun/projectile/shotgun/combat = /obj/item/weapon/gun/energy/lasercannon,
		/obj/item/weapon/gun/projectile/grenade_launcher = /obj/item/weapon/gun/energy/sniperrifle,
		/obj/item/ammo_box/shotgun/beanbag = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/teargas = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/EMP = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/rubber = /obj/item/ammo_box/magazine/plasma,
	)
