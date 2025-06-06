//Captain's Spacesuit
/obj/item/clothing/head/helmet/space/capspace
	name = "space helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | PHORONGUARD
	render_flags = parent_type::render_flags | HIDE_ALL_HAIR
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	permeability_coefficient = 0.01
	armor = list(melee = 65, bullet = 55, laser = 50,energy = 25, bomb = 50, bio = 100, rad = 50)
	siemens_coefficient = 0.4

//Captain's space suit This is not the proper path but I don't currently know enough about how this all works to mess with it.
/obj/item/clothing/suit/armor/captain
	name = "captain's armor"
	desc = "A bulky, heavy-duty piece of exclusive Nanotrasen armor. YOU are in charge!"
	icon_state = "caparmor"
	item_state = "capspacesuit"
	w_class = SIZE_NORMAL
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_box/magazine, /obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/handcuffs, /obj/item/weapon/tank/jetpack)
	slowdown = 0.7
	armor = list(melee = 65, bullet = 55, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	render_flags = parent_type::render_flags | HIDE_TAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4
