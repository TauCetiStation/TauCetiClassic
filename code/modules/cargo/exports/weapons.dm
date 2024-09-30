// Weapon exports. Stun batons, disablers, etc.

/datum/export/weapon
	include_subtypes = FALSE

/datum/export/weapon/baton
	cost = 50
	unit_name = "stun baton"
	export_types = list(/obj/item/weapon/melee/baton)

/datum/export/weapon/taser
	cost = 50
	unit_name = "taser"
	export_types = list(/obj/item/weapon/gun/energy/taser)

//--------------------------------------------
//----------------energy weapons--------------
//--------------------------------------------

/datum/export/weapon/laser
	cost = 450 //ordinary laser rifle
	unit_name = "laser gun"
	export_types = list(/obj/item/weapon/gun/energy/laser)

/datum/export/weapon/energy_gun
	cost = 400
	unit_name = "energy gun"
	export_types = list(/obj/item/weapon/gun/energy/gun,
										/obj/item/weapon/gun/energy)

/datum/export/weapon/sniper_rifle
	cost = 800
	unit_name = "sniper rifle"
	export_types = list(/obj/item/weapon/gun/energy/sniperrifle)

/datum/export/weapon/ion_rifle
	cost = 750
	unit_name = "ion rifle"
	export_types = list(/obj/item/weapon/gun/energy/ionrifle)

/datum/export/weapon/pyrometer
	cost = 25
	unit_name = "pyrometer"
	include_subtypes = TRUE
	export_types = list(/obj/item/weapon/gun/energy/pyrometer)

/datum/export/weapon/kinetic
	cost = 500
	unit_name = "kinetic accelerator"
	export_types = list(/obj/item/weapon/gun/energy/kinetic_accelerator)

/datum/export/weapon/plasma_cutter
	cost = 500
	unit_name = "plasma cutter"
	export_types = list(/obj/item/projectile/beam/plasma_cutter)


//--------------------------------------------
//----------------ballistic weapons-----------
//--------------------------------------------

/datum/export/weapon/combat_shotgun
	cost = 500
	unit_name = "combat shotgun"
	export_types = list(/obj/item/weapon/gun/projectile/shotgun/combat)

/datum/export/weapon/shotgun
	cost = 300 //cheap and old shotgun
	unit_name = "shotgun"
	export_types = list(/obj/item/weapon/gun/projectile/shotgun)

/datum/export/weapon/glock
	cost = 400
	unit_name = "Glock 17"
	export_types = list(/obj/item/weapon/gun/projectile/automatic/pistol/glock)

/datum/export/weapon/l13
	cost = 600
	unit_name = "L13 SMG"
	export_types = list(/obj/item/weapon/gun/projectile/automatic/l13)

/datum/export/weapon/m79
	cost = 350
	unit_name = "M79"
	export_types = list(/obj/item/weapon/gun/projectile/grenade_launcher/m79)

//--------------------------------------------
//----------------MISC------------------------
//--------------------------------------------

/datum/export/weapon/flashbang
	cost = 15
	unit_name = "flashbang grenade"
	export_types = list(/obj/item/weapon/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 15
	unit_name = "tear gas grenade"
	export_types = list(/obj/item/weapon/grenade/chem_grenade/teargas)

/datum/export/weapon/flash
	cost = 5
	unit_name = "handheld flash"
	export_types = list(/obj/item/device/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 1
	unit_name = "pair"
	message = "of handcuffs"
	export_types = list(/obj/item/weapon/handcuffs)

/datum/export/weapon/flamethrower
	cost = 50
	unit_name = "flamethrower"
	export_types = list(/obj/item/weapon/flamethrower)

/datum/export/weapon/shock_mine
	cost = 50
	unit_name = "shock mine"
	export_types = list(/obj/item/mine/shock)
