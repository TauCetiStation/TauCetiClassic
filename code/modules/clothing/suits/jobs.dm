/*
 * Job related
 */

//Botonist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "overalls"
	blood_overlay_type = "armor"
	body_parts_covered = 0
	allowed = list (/obj/item/weapon/reagent_containers/spray/plantbgone,/obj/item/device/plant_analyzer,/obj/item/seeds,/obj/item/nutrient,/obj/item/weapon/minihoe)

//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/captunic/capjacket
	name = "captain's uniform jacket"
	desc = "A less formal jacket for everyday captain use."
	icon_state = "capjacket"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

//Chaplain
/obj/item/clothing/suit/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/hooded/skhima
	name = "Skhima Suit"
	desc = "That's an ancient religion robe Skhima, decorated with white runes and symbols. Commonly weared by monks."
	icon_state = "skhima"
	item_state = "skhima"
	icon_suit_up = "skhima_up"
	hoodtype = /obj/item/clothing/head/skhima_hood
	flags_inv = HIDEJUMPSUIT
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	allowed = list (/obj/item/weapon/storage/bible,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/device/pda,
					/obj/item/weapon/lighter,
					/obj/item/weapon/storage/fancy/crayons,
					/obj/item/weapon/paper)

/obj/item/clothing/suit/hooded/nun
	name = "nun robe"
	desc = "A religion female suit commonly weared by monastery sisters."
	icon_state = "nun"
	item_state = "nun"
	var/sleeves = TRUE
	hoodtype = /obj/item/clothing/head/nun_hood
	flags_inv = HIDEJUMPSUIT
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	allowed = list (/obj/item/weapon/storage/bible,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/device/pda,
					/obj/item/weapon/lighter,
					/obj/item/weapon/storage/fancy/crayons,
					/obj/item/weapon/paper)

/obj/item/clothing/suit/hooded/nun/verb/adjust_sleeves()
	set name = "Toggle Sleeves"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	if(sleeves)
		icon_state = "nun_rolled"
		to_chat(usr, "You roll up your sleeves.")
		sleeves = FALSE
	else
		icon_state = "nun"
		to_chat(usr, "You let off your sleeves.")
		sleeves = TRUE
	usr.update_inv_wear_suit()

//Chef
/obj/item/clothing/suit/chef
	name = "chef's apron"
	desc = "An apron used by a high class chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/weapon/kitchenknife)

//Chef
/obj/item/clothing/suit/chef/classic
	name = "A classic chef's apron."
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = 0

//Detective
/obj/item/clothing/suit/storage/det_suit
	name = "brown coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective_brown"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	body_parts_covered = UPPER_TORSO|ARMS
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/det_suit/grey
	name = "grey coat"
	icon_state = "detective_grey"

/obj/item/clothing/suit/storage/det_suit/black
	name = "black coat"
	desc = "An 20th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "maxcoat"

/obj/item/clothing/suit/storage/det_suit/noir_trenchcoat
	name = "dark grey trenchcoat"
	desc = "A hard-boiled private investigator's dark grey trenchcoat."
	icon_state = "trenchcoat_darkgrey"
	item_state = "trenchcoat_darkgrey"

//Forensics
/obj/item/clothing/suit/storage/forensics
	name = "jacket"
	desc = "A forensics technician jacket."
	item_state = "det_suit"
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	body_parts_covered = UPPER_TORSO|ARMS
	armor = list(melee = 10, bullet = 10, laser = 15, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/forensics/red
	name = "red jacket"
	desc = "A red forensics technician jacket."
	icon_state = "forensics_red"

/obj/item/clothing/suit/storage/forensics/blue
	name = "blue jacket"
	desc = "A blue forensics technician jacket."
	icon_state = "forensics_blue"

//Engineering
/obj/item/clothing/suit/storage/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard_orange"
	item_state = "hazard_orange"
	blood_overlay_type = "armor"
	allowed = list (/obj/item/device/analyzer, /obj/item/device/flashlight, /obj/item/device/multitool, /obj/item/device/radio, /obj/item/device/t_scanner,
	/obj/item/weapon/crowbar, /obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench, /obj/item/weapon/tank/emergency_oxygen,
	/obj/item/clothing/mask/gas, /obj/item/taperoll/engineering)
	body_parts_covered = UPPER_TORSO

/obj/item/clothing/suit/storage/hazardvest/atom_init()
	. = ..()
	var/vest_color = pick("orange", "black")
	icon_state = "hazard_[vest_color]"
	item_state = icon_state
	desc = "A high-visibility [vest_color] vest used in work zones."

//Lawyer
/obj/item/clothing/suit/storage/lawyer/bluejacket
	name = "blue suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/storage/lawyer/purpjacket
	name = "purple suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_purp"
	item_state = "suitjacket_purp"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

//Internal Affairs
/obj/item/clothing/suit/storage/internalaffairs
	name = "internal affairs jacket"
	desc = "A smooth black jacket."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/storage/internalaffairs/verb/toggle()
	set name = "Toggle Coat Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	switch(icon_state)
		if("ia_jacket_open")
			src.icon_state = "ia_jacket"
			to_chat(usr, "You button up the jacket.")
		if("ia_jacket")
			src.icon_state = "ia_jacket_open"
			to_chat(usr, "You unbutton the jacket.")
		else
			to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how retarded you are.")
			return
	usr.update_inv_wear_suit()	//so our overlays update

//Medical
/obj/item/clothing/suit/storage/fr_jacket
	name = "first responder jacket"
	desc = "A high-visibility jacket worn by medical first responders."
	icon_state = "fr_jacket_open"
	item_state = "fr_jacket"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/stack/medical, /obj/item/weapon/reagent_containers/dropper, /obj/item/weapon/reagent_containers/hypospray, /obj/item/weapon/reagent_containers/syringe,
	/obj/item/device/healthanalyzer, /obj/item/device/flashlight, /obj/item/device/radio, /obj/item/weapon/tank/emergency_oxygen)
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/storage/fr_jacket/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	switch(icon_state)
		if("fr_jacket_open")
			src.icon_state = "fr_jacket"
			to_chat(usr, "You button up the jacket.")
		if("fr_jacket")
			src.icon_state = "fr_jacket_open"
			to_chat(usr, "You unbutton the jacket.")
	usr.update_inv_wear_suit()	//so our overlays update

//Mime
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here
	body_parts_covered = 0

//Recycler
/obj/item/clothing/suit/recyclervest
    name = "recycler vest"
    desc = "This is Recycler vest."
    icon = 'icons/obj/clothing/suits.dmi'
    icon_state = "recycler_vest_open"
    item_state = "recycler_vest"
    blood_overlay_type = "coat" //it's the less thing that I can put here
    body_parts_covered = 0
    action_button_name = "Toggle vest buttons"

/obj/item/clothing/suit/recyclervest/ui_action_click()
    toggle()

/obj/item/clothing/suit/recyclervest/proc/toggle()
    switch(icon_state)
        if("recycler_vest_open")
            src.icon_state = "recycler_vest"
            to_chat(usr, "You button up the vest.")
        if("recycler_vest")
            src.icon_state = "recycler_vest_open"
            to_chat(usr, "You unbutton the jacket.")
        else
            to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how retarded you are.")
            return
    usr.update_inv_wear_suit()    //so our overlays update

/obj/item/clothing/suit/surgicalapron
	name = "surgical apron"
	desc = "A sterile blue apron for performing surgery."
	icon_state = "surgical"
	item_state = "surgical"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/stack/medical, /obj/item/weapon/reagent_containers/dropper, /obj/item/weapon/reagent_containers/hypospray, /obj/item/weapon/reagent_containers/syringe,
	/obj/item/device/healthanalyzer, /obj/item/device/flashlight, /obj/item/device/radio, /obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/scalpel,/obj/item/weapon/retractor,/obj/item/weapon/hemostat,
	/obj/item/weapon/cautery,/obj/item/weapon/bonegel,/obj/item/weapon/FixOVein)
