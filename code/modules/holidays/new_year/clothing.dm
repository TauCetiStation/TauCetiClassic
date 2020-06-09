
//////////////////////////////////////////////
////////////Santa suit & hat//////////////////
//////////////////////////////////////////////

/obj/item/clothing/head/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags = HEADCOVERSEYES | BLOCKHAIR
	body_parts_covered = HEAD

/obj/item/clothing/suit/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	allowed = list(/obj/item) //for stuffing exta special presents


//////////////////////////////////////////////
////////////Winter suits//////////////////////
//////////////////////////////////////////////

/obj/item/clothing/proc/can_use(mob/living/user) // Checking if mob can use the object eg restrained and other
	return istype(user) && !user.incapacitated()

/obj/item/clothing/suit/wintercoat/attack_self() // Refactored function for using coat's hood by clicking on it

	if(!can_use(usr))
		return 0
	if(ishuman(usr))
		var/mob/living/carbon/human/C = usr
		if(C.head)
			to_chat(C, "<span class='warning'>You're wearing something on your head!</span>")
			return
	src.hooded = !src.hooded

	if(!src.hooded)
		src.icon_state = "[initial(icon_state)]"
		to_chat(usr, "You toggle off [src]'s hood.")
	else
		src.icon_state = "[initial(icon_state)]_t"
		to_chat(usr, "You toggle on [src]'s hood.")
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_hair(0) // only human type has hair
	usr.update_inv_head(0)
	usr.update_inv_wear_suit()

/obj/item/clothing/suit/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_custom = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_state = "coatwinter"
	item_state = "coatwinter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)
	action_button_name = "Toggle Winter Hood"

	var/hooded = 0

/obj/item/clothing/suit/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "coatcaptain"
	armor = list(melee = 50, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/telebaton)

/obj/item/clothing/suit/wintercoat/security
	name = "security winter coat"
	icon_state = "coatsecurity"
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/telebaton)

/obj/item/clothing/suit/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/weapon/melee/telebaton)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)

/obj/item/clothing/suit/wintercoat/science
	name = "science winter coat"
	icon_state = "coatscience"
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/weapon/melee/telebaton)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/t_scanner, /obj/item/weapon/rcd)

/obj/item/clothing/suit/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"

/obj/item/clothing/suit/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"
	allowed = list(/obj/item/weapon/reagent_containers/spray/plantbgone,/obj/item/device/plant_analyzer,/obj/item/seeds,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/minihoe,/obj/item/weapon/hatchet,/obj/item/weapon/storage/bag/plants)

/obj/item/clothing/suit/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "coatcargo"

/obj/item/clothing/suit/wintercoat/miner
	name = "mining winter coat"
	icon_state = "coatminer"
	allowed = list(/obj/item/weapon/pickaxe,/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_custom = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_state = "winterboots"
	item_state = "winterboots"
	cold_protection = LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS


/obj/item/clothing/suit/storage/labcoat/winterlabcoat
	name = "winter labcoat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_custom = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_state = "labcoat_emt"
	item_state = "labcoat_emt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_custom = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_state = "ushankadown"
	item_state = "ushankadown"
	cold_protection = HEAD

/obj/item/clothing/head/ushanka/attack_self(mob/user)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		to_chat(user, "You lower the ear flaps on the ushanka.")

/obj/item/clothing/head/santa
	name = "christmas hat"
	desc = "Perfect for hot winter in Siberia, da?"
	icon = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_custom = 'code/modules/holidays/new_year/winter_suits.dmi'
	icon_state = "santa"
	item_state = "santa"
	flags_inv = HIDEEARS
	cold_protection = HEAD

/obj/item/clothing/under/sexy_santa
	name = "sexy santa suit"
	desc = "Prepare to jingle all the bells."
	icon_state = "sexy_santa"
	item_state = "sexy_santa"
	item_color = "sexy_santa"
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
