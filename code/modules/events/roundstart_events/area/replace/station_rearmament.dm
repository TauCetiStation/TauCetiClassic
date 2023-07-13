/datum/event/feature/area/replace/station_rearmament_bullets
	special_area_types = list(/area/station/security/warden, /area/station/security/armoury, /area/station/security/hos,
	/area/station/security/main, /area/station/security/checkpoint, /area/station/medical/reception, /area/station/bridge)
	replace_types = list(
		/obj/item/weapon/gun/energy/gun/head = /obj/item/weapon/gun/projectile/revolver/detective,
		/obj/item/weapon/gun/energy/taser = /obj/item/weapon/gun/projectile/automatic/pistol/glock,
		/obj/item/weapon/gun/plasma = /obj/item/weapon/gun/projectile/revolver/doublebarrel,
		/obj/item/weapon/gun/energy/laser = /obj/item/weapon/gun/projectile/automatic/l13,
		/obj/item/weapon/gun/energy/gun/hos = /obj/item/weapon/gun/projectile/automatic/pistol/glock/spec,
		/obj/item/ammo_box/magazine/plasma = /obj/item/ammo_box/shotgun/beanbag,
		/obj/item/weapon/gun/energy/gun = /obj/item/ammo_box/magazine/l13,
		/obj/structure/displaycase/captain = /obj/structure/displaycase/captain, //so that weapons in displaycase are not deleted
	)

/datum/event/feature/area/replace/station_rearmament_energy
	special_area_types = list(/area/station/security/warden, /area/station/security/armoury, /area/station/security/hos,
	/area/station/security/main, /area/station/security/checkpoint, /area/station/medical/reception, /area/station/bridge)
	replace_types = list(
		/obj/item/weapon/gun/energy/taser = /obj/item/weapon/gun/energy/taser/stunrevolver,
		/obj/item/weapon/gun/projectile/automatic/pistol/glock = /obj/item/weapon/gun/energy/taser/stunrevolver,
		/obj/item/ammo_box/magazine/glock/rubber = /obj/item/device/radio_grid,
		/obj/item/ammo_box/magazine/glock = /obj/item/weapon/grenade/empgrenade,
		/obj/item/weapon/gun/projectile/shotgun/combat = /obj/item/weapon/gun/energy/lasercannon,
		/obj/item/weapon/gun/projectile/grenade_launcher = /obj/item/weapon/gun/energy/sniperrifle,
		/obj/item/ammo_box/shotgun/beanbag = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/teargas = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/EMP = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/rubber = /obj/item/ammo_box/magazine/plasma,
	)
