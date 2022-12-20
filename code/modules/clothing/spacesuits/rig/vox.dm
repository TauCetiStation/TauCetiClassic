// Vox space gear (hardsuit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.
/obj/item/clothing/suit/space/rig/vox
	w_class = SIZE_SMALL
	allowed = list(/obj/item/weapon/gun,
	/obj/item/ammo_box/magazine,
	/obj/item/ammo_casing,
	/obj/item/weapon/melee/baton,
	/obj/item/weapon/melee/energy/sword,
	/obj/item/weapon/handcuffs,
	/obj/item/weapon/tank)
	slowdown = 0.7
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 15, bomb = 30, bio = 30, rad = 30)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(VOX , VOX_ARMALIS)
	breach_threshold = 30
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/emp_shield)
	cell_type = /obj/item/weapon/stock_parts/cell/super
	rig_variant = "vox"
	max_mounted_devices = 7

/obj/item/clothing/head/helmet/space/rig/vox
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 15, bomb = 30, bio = 30, rad = 30)
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/head/helmet/space/rig/vox/atom_init()
	. = ..()
	holochip = new /obj/item/holochip/vox(src)
	holochip.holder = src

/obj/item/clothing/head/helmet/space/rig/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	siemens_coefficient = 0
	armor = list(melee = 80, bullet = 75, laser = 50, energy = 10, bomb = 35, bio = 30, rad = 30)

/obj/item/clothing/suit/space/rig/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	slowdown = 1
	siemens_coefficient = 0
	armor = list(melee = 80, bullet = 75, laser = 50, energy = 10, bomb = 35, bio = 30, rad = 30)
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/rcd, /obj/item/rig_module/device/extinguisher, /obj/item/rig_module/cooling_unit, /obj/item/rig_module/emp_shield)

/obj/item/clothing/head/helmet/space/rig/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	armor = list(melee = 65, bullet = 50, laser = 70, energy = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/rig/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	armor = list(melee = 65, bullet = 50, laser = 70, energy = 20, bomb = 30, bio = 30, rad = 30)
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/emp_shield,  /obj/item/rig_module/mounted/taser, /obj/item/rig_module/grenade_launcher/flashbang, /obj/item/rig_module/device/flash)

/obj/item/clothing/head/helmet/space/rig/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."
	armor = list(melee = 50, bullet = 40, laser = 45, energy = 15, bomb = 25, bio = 30, rad = 30)

/obj/item/clothing/suit/space/rig/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."
	slowdown = 0.5
	armor = list(melee = 50, bullet = 40, laser = 45, energy = 15, bomb = 25, bio = 30, rad = 30)
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/emp_shield, /obj/item/rig_module/selfrepair, /obj/item/rig_module/chem_dispenser/medical/vox, /obj/item/rig_module/device/healthscanner)

/obj/item/clothing/head/helmet/space/rig/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."
	armor = list(melee = 45, bullet = 20, laser = 25, energy = 5, bomb = 15, bio = 30, rad = 30)

/obj/item/clothing/suit/space/rig/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very light."
	armor = list(melee = 45, bullet = 20, laser = 25, energy = 5, bomb = 15, bio = 30, rad = 30)
	slowdown = 0.2
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash, /obj/item/rig_module/stealth, /obj/item/rig_module/nuclear_generator)


//Just clothing

/obj/item/clothing/under/vox
	has_sensor = 0
	species_restricted = list(VOX)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	item_state = "vox-casual-1"
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	item_state = "vox-casual-2"

/obj/item/clothing/gloves/yellow/vox
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	name = "insulated gauntlets"
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/shoes/magboots/vox
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	name = "vox magclaws"
	item_state = "boots-vox0"
	icon_state = "boots-vox"

	species_restricted = list(VOX , VOX_ARMALIS)
	action_button_name = "Toggle the magclaws"
