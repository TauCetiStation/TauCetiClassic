
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
/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	hoodtype = /obj/item/clothing/head/wintercoat
	icon_state = "coatwinter"
	item_state = "coatwinter"
	icon_suit_up = "coatwinter_t" // see /atom_init()

	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)

/obj/item/clothing/suit/hooded/wintercoat/atom_init()
	. = ..()
	icon_suit_up = "[icon_state]_t"

/obj/item/clothing/head/wintercoat
	name = "winter hood"
	icon_state = "coatwinter_hood"
	cold_protection = HEAD
	flags = BLOCKHEADHAIR
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "coatcaptain"
	hoodtype = /obj/item/clothing/head/wintercoat/captain
	armor = list(melee = 35, bullet = 25, laser = 20, energy = 10, bomb = 15, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/plasma,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/telebaton)

/obj/item/clothing/head/wintercoat/captain
	name = "captain's winter hood"
	icon_state = "coatcaptain_hood"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	icon_state = "coatsecurity"
	hoodtype = /obj/item/clothing/head/wintercoat/security
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 25, bomb = 25, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/plasma,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/telebaton)

/obj/item/clothing/head/wintercoat/security
	name = "security winter hood"
	icon_state = "coatsecurity_hood"

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	hoodtype = /obj/item/clothing/head/wintercoat/medical
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/weapon/melee/telebaton)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)

/obj/item/clothing/head/wintercoat/medical
	name = "medical winter hood"
	icon_state = "coatmedical_hood"

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	icon_state = "coatscience"
	hoodtype = /obj/item/clothing/head/wintercoat/science
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/weapon/melee/telebaton)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/head/wintercoat/science
	name = "science winter hood"
	icon_state = "coatscience_hood"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	hoodtype = /obj/item/clothing/head/wintercoat/engineering
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/t_scanner, /obj/item/weapon/rcd)

/obj/item/clothing/head/wintercoat/engineering
	name = "engineering winter hood"
	icon_state = "coatengineer_hood"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/wintercoat/engineering/atmos

/obj/item/clothing/head/wintercoat/engineering/atmos
	name = "atmospherics winter hood"
	icon_state = "coatatmos_hood"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"
	hoodtype = /obj/item/clothing/head/wintercoat/hydro
	allowed = list(/obj/item/weapon/reagent_containers/spray/plantbgone,/obj/item/device/plant_analyzer,/obj/item/seeds,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/minihoe,/obj/item/weapon/hatchet,/obj/item/weapon/storage/bag/plants)

/obj/item/clothing/head/wintercoat/hydro
	name = "hydroponics winter hood"
	icon_state = "coathydro_hood"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/wintercoat/cargo

/obj/item/clothing/head/wintercoat/cargo
	name = "cargo winter hood"
	icon_state = "coatcargo_hood"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	icon_state = "coatminer"
	hoodtype = /obj/item/clothing/head/wintercoat/miner
	allowed = list(/obj/item/weapon/pickaxe,/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/wintercoat/miner
	name = "mining winter hood"
	icon_state = "coatminer_hood"

/obj/item/clothing/suit/hooded/wintercoat/wiz_blue
	name = "Blue wizard winter coat"
	icon_state = "coatwizblue"
	hoodtype = /obj/item/clothing/head/wintercoat/wiz_blue

/obj/item/clothing/head/wintercoat/wiz_blue
	name = "Blue wizard winter hood"
	icon_state = "coatwizblue_hood"

/obj/item/clothing/suit/hooded/wintercoat/wiz_red
	name = "Red wizard winter coat"
	icon_state = "coatwizred"
	hoodtype = /obj/item/clothing/head/wintercoat/wiz_red

/obj/item/clothing/head/wintercoat/wiz_red
	name = "Red wizard winter hood"
	icon_state = "coatwizred_hood"

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	item_state = "winterboots"
	cold_protection = LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS

/obj/item/clothing/shoes/winterboots/wizard

/obj/item/clothing/shoes/winterboots/wizard/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/suit/storage/labcoat/winterlabcoat
	name = "winter labcoat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "labcoat_emt"
	item_state = "labcoat_emt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)

/obj/item/clothing/head/santa
	name = "christmas hat"
	desc = "Perfect for hot winter in Siberia, da?"
	icon_state = "santa"
	item_state = "santa"
	flags_inv = HIDEEARS
	cold_protection = HEAD

/obj/item/clothing/under/sexy_santa
	name = "sexy santa suit"
	desc = "Prepare to jingle all the bells."
	icon_state = "sexy_santa"
	item_state = "sexy_santa"
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
