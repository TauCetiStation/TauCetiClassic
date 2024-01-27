/datum/event/feature/area/replace/station_rearmament_bullets
	special_area_types = list(/area/station/security/armoury)
	replace_types = list(
		/obj/item/weapon/gun/plasma = /obj/item/weapon/gun/projectile/revolver/doublebarrel,
		/obj/item/weapon/gun/energy/laser = /obj/item/weapon/gun/projectile/automatic/l13,
		/obj/item/ammo_box/magazine/plasma = /obj/item/ammo_box/shotgun/beanbag,
		/obj/item/weapon/gun/energy/gun = /obj/item/ammo_box/magazine/l13,
	)

/datum/event/feature/area/replace/station_rearmament_energy
	special_area_types = list(/area/station/security/armoury)
	replace_types = list(
		/obj/item/ammo_box/magazine/glock/rubber = /obj/item/device/radio_grid,
		/obj/item/ammo_box/magazine/glock = /obj/item/weapon/grenade/empgrenade,
		/obj/item/weapon/gun/projectile/shotgun/combat = /obj/item/weapon/gun/energy/lasercannon,
		/obj/item/weapon/gun/projectile/grenade_launcher = /obj/item/weapon/gun/energy/sniperrifle,
		/obj/item/ammo_box/shotgun/beanbag = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/teargas = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/EMP = /obj/item/ammo_box/magazine/plasma,
		/obj/item/weapon/storage/box/r4046/rubber = /obj/item/ammo_box/magazine/plasma,
	)

/datum/event/feature/area/replace/sec_rearmament_elite
	special_area_types = list(/area/station/security/armoury)
	replace_types = list(
		/obj/item/weapon/shield/riot = /obj/item/weapon/shield/riot/tele,
		/obj/item/ammo_box/shotgun/beanbag = /obj/item/ammo_box/eight_shells/stunshot,
		/obj/item/weapon/gun/energy/laser = /obj/item/weapon/gun/energy/lasercannon,
		/obj/item/weapon/gun/energy/gun = /obj/item/weapon/gun/energy/gun/nuclear,
	)
