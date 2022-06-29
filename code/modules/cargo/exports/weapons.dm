// Weapon exports. Stun batons, disablers, etc.

/datum/export/weapon
	include_subtypes = FALSE

/datum/export/weapon/baton
	cost = 15
	unit_name = "stun baton"
	export_types = list(/obj/item/weapon/melee/baton)

/datum/export/weapon/taser
	cost = 40
	unit_name = "taser"
	export_types = list(/obj/item/weapon/gun/energy/taser)

/datum/export/weapon/laser
	cost = 20
	unit_name = "laser gun"
	export_types = list(/obj/item/weapon/gun/energy/laser)

/datum/export/weapon/energy_gun
	cost = 25
	unit_name = "energy gun"
	export_types = list(/obj/item/weapon/gun/energy/gun,
										/obj/item/weapon/gun/energy)

/datum/export/weapon/nuclear
	cost = 100
	unit_name = "advanced e-gun"
	export_types = list(/obj/item/weapon/gun/energy/gun/nuclear)

/datum/export/weapon/cannon
	cost = 200
	unit_name = "laser cannon"
	export_types = list(/obj/item/weapon/gun/energy/lasercannon)

/datum/export/weapon/xray
	cost = 150
	unit_name = "xray laser gun"
	export_types = list(/obj/item/weapon/gun/energy/xray)

/datum/export/weapon/stunrevolver
	cost = 75
	unit_name = "stun revolver"
	export_types = list(/obj/item/weapon/gun/energy/taser/stunrevolver)

/datum/export/weapon/shotgun
	cost = 600
	unit_name = "combat shotgun"
	export_types = list(/obj/item/weapon/gun/projectile/shotgun/combat)

/datum/export/weapon/revolver
	cost = 1000
	unit_name = "revolver"
	export_types = list(/obj/item/weapon/gun/projectile/revolver)

/datum/export/weapon/auto
	cost = 150
	unit_name = "automatic weapon"
	export_types = list(/obj/item/weapon/gun/projectile/automatic)
	include_subtypes = TRUE

/datum/export/weapon/auto/stechkin
	cost = 800
	unit_name = "stechkin pistol"
	export_types = list(/obj/item/weapon/gun/projectile/automatic/pistol)

/datum/export/weapon/auto/glock
	cost = 15
	unit_name = "G17"
	export_types = list(/obj/item/weapon/gun/projectile/glock)

/datum/export/weapon/esword
	cost = 900
	unit_name = "energy sword"
	export_types = list(/obj/item/weapon/melee/energy/sword)
	include_subtypes = TRUE

/datum/export/weapon/dualsaber
	cost = 2500
	unit_name = "double-bladed energy sword"
	export_types = list(/obj/item/weapon/dualsaber)

/datum/export/weapon/flashbang
	cost = 5
	unit_name = "flashbang grenade"
	export_types = list(/obj/item/weapon/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 15
	unit_name = "tear gas grenade"
	export_types = list(/obj/item/weapon/grenade/chem_grenade/teargas)


/datum/export/weapon/flash
	cost = 10
	unit_name = "handheld flash"
	export_types = list(/obj/item/device/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 3
	unit_name = "pair"
	message = "of handcuffs"
	export_types = list(/obj/item/weapon/handcuffs)
