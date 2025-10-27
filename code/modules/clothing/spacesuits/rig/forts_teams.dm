// ert rigs copypaste

// common setup
/obj/item/clothing/head/helmet/space/rig/forts
	name = "forts team helmet"
	armor = list(melee = 50, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	can_be_modded = FALSE

	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES//|HIDEFACE

/obj/item/clothing/suit/space/rig/forts
	name = "forts team suit"
	w_class = SIZE_SMALL
	can_be_modded = FALSE
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,
	/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,
	/obj/item/weapon/tank,/obj/item/weapon/rcd, /obj/item/device/multitool)
	slowdown = 0.5
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_mounted_devices = 6
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair)

// team red
/obj/item/clothing/head/helmet/space/rig/forts/team_red
	icon_state = "rig0-ert_security"
	item_state = "ert_security"
	rig_variant = "ert_security"

/obj/item/clothing/head/helmet/space/rig/forts/team_red/atom_init()
	. = ..()
	holochip = new /obj/item/holochip/team_red(src)
	holochip.holder = src

/obj/item/clothing/suit/space/rig/forts/team_red
	icon_state = "ert_security"
	item_state = "ert_security"

// team blue
/obj/item/clothing/head/helmet/space/rig/forts/team_blue
	icon_state = "rig0-ert_commander"
	item_state = "ert_commander"
	rig_variant = "ert_commander"

/obj/item/clothing/head/helmet/space/rig/forts/team_blue/atom_init()
	. = ..()
	holochip = new /obj/item/holochip/team_blue(src)
	holochip.holder = src

/obj/item/clothing/suit/space/rig/forts/team_blue
	icon_state = "ert_commander"
	item_state = "ert_commander"
