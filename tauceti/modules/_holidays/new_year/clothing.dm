//////////////////////////////////////////////
////////////Santa suit & hat//////////////////
//////////////////////////////////////////////

/obj/item/clothing/head/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | BLOCKHAIR
	body_parts_covered = HEAD

/obj/item/clothing/suit/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	flags = FPRINT | TABLEPASS
	allowed = list(/obj/item) //for stuffing exta special presents


//////////////////////////////////////////////
////////////Winter suits//////////////////////
//////////////////////////////////////////////

/obj/item/clothing/suit/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	tc_custom = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	flags = FPRINT | TABLEPASS
	icon_state = "coatwinter"
	item_state = "coatwinter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)

/obj/item/clothing/suit/wintercoat/verb/toggle()
	set name = "Toggle Winter Hood"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained())
		return 0

	switch(icon_state)
		if("coatwinter")
			src.icon_state = "coatwinter_t"
			usr << "You hood up the coat."
		if("coatwinter_t")
			src.icon_state = "coatwinter"
			usr << "You unhood the coat."
		if("coatcaptain")
			src.icon_state = "coatcaptain_t"
			usr << "You hood up the coat."
		if("coatcaptain_t")
			src.icon_state = "coatcaptain"
			usr << "You unhood the coat."
		if("coatsecurity")
			src.icon_state = "coatsecurity_t"
			usr << "You hood up the coat."
		if("coatsecurity_t")
			src.icon_state = "coatsecurity"
			usr << "You unhood the coat."
		if("coatmedical")
			src.icon_state = "coatmedical_t"
			usr << "You hood up the coat."
		if("coatmedical_t")
			src.icon_state = "coatmedical"
			usr << "You unhood the coat."
		if("coatscience")
			src.icon_state = "coatscience_t"
			usr << "You hood up the coat."
		if("coatscience_t")
			src.icon_state = "coatscience"
			usr << "You unhood the coat."
		if("coatengineer")
			src.icon_state = "coatengineer_t"
			usr << "You hood up the coat."
		if("coatengineer_t")
			src.icon_state = "coatengineer"
			usr << "You unhood the coat."
		if("coatatmos")
			src.icon_state = "coatatmos_t"
			usr << "You hood up the coat."
		if("coatatmos_t")
			src.icon_state = "coatatmos"
			usr << "You unhood the coat."
		if("coathydro")
			src.icon_state = "coathydro_t"
			usr << "You hood up the coat."
		if("coathydro_t")
			src.icon_state = "coathydro"
			usr << "You unhood the coat."
		if("coatminer")
			src.icon_state = "coatminer_t"
			usr << "You hood up the coat."
		if("coatminer_t")
			src.icon_state = "coatminer"
			usr << "You unhood the coat."
		if("coatcargo")
			src.icon_state = "coatcargo_t"
			usr << "You hood up the coat."
		if("coatcargo_t")
			src.icon_state = "coatcargo"
			usr << "You unhood the coat."
		else
			usr << "You attempt to hood-up the velcro on your [src], before promptly realising how silly you are."
			return
	usr.update_inv_wear_suit()	//so our overlays update

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
	allowed = list(/obj/item/weapon/reagent_containers/spray/plantbgone,/obj/item/device/analyzer/plant_analyzer,/obj/item/seeds,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/minihoe,/obj/item/weapon/hatchet,/obj/item/weapon/storage/bag/plants)

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
	icon = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	tc_custom = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	icon_state = "winterboots"
	item_state = "winterboots"
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET|LEGS

/obj/item/clothing/suit/winterlabcoat
	name = "winter labcoat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	tc_custom = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	flags = FPRINT | TABLEPASS
	icon_state = "labcoat_emt"
	item_state = "labcoat_emt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)


/obj/item/clothing/suit/winterlabcoat/verb/toggle2()
	set name = "Toggle Button"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained())
		return 0

	switch(icon_state)
		if("labcoat_emt")
			src.icon_state = "labcoat_emt_t"
			usr << "You unbutton the coat."
		if("labcoat_emt_t")
			src.icon_state = "labcoat_emt"
			usr << "You button up the coat."
	usr.update_inv_wear_suit()

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	tc_custom = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	icon_state = "ushankadown"
	item_state = "ushankadown"
	cold_protection = HEAD

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."

/obj/item/clothing/head/santa
	name = "Ded moroz hat"
	desc = "Perfect for hot winter in Siberia, da?"
	icon = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	tc_custom = 'tauceti/modules/_holidays/new_year/winter_suits.dmi'
	icon_state = "santa"
	item_state = "santa"
	flags_inv = HIDEEARS
	cold_protection = HEAD