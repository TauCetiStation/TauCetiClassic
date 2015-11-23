/***********-White-***********/
/obj/item/clothing/suit/space/globose
	icon_state = "glob_white"

/obj/item/clothing/head/helmet/space/globose
	icon_state = "glob0_white"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL | PHORONGUARD
	var/mode = "white"
	var/visor = 0

	action_button_name = "Toggle Helmet Visor"

/obj/item/clothing/head/helmet/space/globose/attack_self(mob/user)
	visor = !visor
	icon_state = "glob[visor]_[mode]"

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()


/***********-Yellow-***********/
/obj/item/clothing/suit/space/globose/yellow
	name = "yellow space suit"
	desc = "A pressure resistant yelloow space suit partially capable of insulating against exotic alien energies."
	icon_state = "glob_yellow"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit)

/obj/item/clothing/head/helmet/space/globose/yellow
	name = "yellow space helmet"
	desc = "A pressure resistant yelloow space helmet partially capable of insulating against exotic alien energies."
	icon_state = "glob0_yellow"
	mode = "yellow"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)

/***********-Black-***********/
/obj/item/clothing/suit/space/globose/black
	name = "black space suit"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."
	icon_state = "glob_black"
	breach_threshold = 22
	slowdown = 1
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)

/obj/item/clothing/head/helmet/space/globose/black
	name = "black space helmet"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."
	icon_state = "glob0_black"
	mode = "black"
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/globose/black/pirate
	name = "balck pirate space helmet"
	desc = "Pirate helmet, which brings horror into people hearts."
	icon_state = "glob0_pirate"
	mode = "pirate"


/***********-Mining-***********/
/obj/item/clothing/suit/space/globose/mining
	name = "mining space suit"
	desc = "Mining space suit that protects against low pressure environments. Has reinforced plating."
	icon_state = "glob_mining"
	breach_threshold = 18
	slowdown = 2
	armor = list(melee = 50, bullet = 5, laser = 10,energy = 5, bomb = 55, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/bag/ore)

/obj/item/clothing/head/helmet/space/globose/mining
	name = "mining space helmet"
	desc = "Mining space helmet that protects against low pressure environments. Has reinforced plating."
	icon_state = "glob0_mining"
	mode = "mining"
	armor = list(melee = 50, bullet = 5, laser = 10,energy = 5, bomb = 55, bio = 100, rad = 20)

