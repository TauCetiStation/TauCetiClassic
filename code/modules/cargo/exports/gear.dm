// Armor, gloves, space suits - it all goes here

/datum/export/gear

// Security gear
/datum/export/gear/sec_helmet
	cost = 20
	include_subtypes = FALSE
	unit_name = "helmet"
	export_types = list(/obj/item/clothing/head/helmet)

/datum/export/gear/sec_armor
	cost = 20
	include_subtypes = FALSE
	unit_name = "armor vest"
	export_types = list(/obj/item/clothing/suit/armor/vest,
									/obj/item/clothing/suit/storage/flak)
	include_subtypes = FALSE


/datum/export/gear/riot_helmet
	cost = 50
	unit_name = "riot helmet"
	export_types = list(/obj/item/clothing/head/helmet/riot)

/datum/export/gear/riot_armor
	cost = 50
	unit_name = "riot armor suit"
	export_types = list(/obj/item/clothing/suit/armor/riot)

/datum/export/gear/bulletproof_helmet
	cost = 50
	unit_name = "bulletproof helmet"
	export_types = list(/obj/item/clothing/head/helmet/bulletproof)

/datum/export/gear/bulletproof_armor
	cost = 50
	unit_name = "bulletproof armor vest"
	export_types = list(/obj/item/clothing/suit/storage/flak/bulletproof)

/datum/export/gear/reflector_helmet
	cost = 130
	unit_name = "reflector helmet"
	export_types = list(/obj/item/clothing/head/helmet/laserproof)

/datum/export/gear/reflector_armor
	cost = 130
	unit_name = "reflector armor vest"
	export_types = list(/obj/item/clothing/suit/armor/laserproof)


/datum/export/gear/riot_shield
	cost = 80
	unit_name = "riot shield"
	export_types = list(/obj/item/weapon/shield/riot)


// Masks
/datum/export/gear/mask/breath
	cost = 1
	unit_name = "breath mask"
	export_types = list(/obj/item/clothing/mask/breath)

/datum/export/gear/mask/gas
	cost = 2
	unit_name = "gas mask"
	export_types = list(/obj/item/clothing/mask/gas/coloured)
	include_subtypes = FALSE



// EVA gear
/datum/export/gear/space
	include_subtypes = TRUE

/datum/export/gear/space/helmet
	cost = 100
	unit_name = "space helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/globose)

/datum/export/gear/space/suit
	cost = 120
	unit_name = "space suit"
	export_types = list(/obj/item/clothing/suit/space/globose)


/datum/export/gear/space/voidhelmet
	cost = 110
	unit_name = "void helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/nasavoid)

/datum/export/gear/space/voidsuit
	cost = 130
	unit_name = "void suit"
	export_types = list(/obj/item/clothing/suit/space/nasavoid)


/datum/export/gear/space/syndiehelmet
	cost = 200
	unit_name = "Syndicate space helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/syndicate)
	include_subtypes = TRUE

/datum/export/gear/space/syndiesuit
	cost = 300
	unit_name = "Syndicate space suit"
	export_types = list(/obj/item/clothing/suit/space/syndicate)
	include_subtypes = TRUE


// Radsuits
/datum/export/gear/radhelmet
	cost = 10
	unit_name = "radsuit hood"
	export_types = list(/obj/item/clothing/head/radiation)

/datum/export/gear/radsuit
	cost = 20
	unit_name = "radsuit"
	export_types = list(/obj/item/clothing/suit/radiation)

// Biosuits
/datum/export/gear/biohood
	cost = 10
	unit_name = "biosuit hood"
	export_types = list(/obj/item/clothing/head/bio_hood)

/datum/export/gear/biosuit
	cost = 20
	unit_name = "biosuit"
	export_types = list(/obj/item/clothing/suit/bio_suit)

// Bombsuits
/datum/export/gear/bombhelmet
	cost = 20
	unit_name = "bomb suit hood"
	export_types = list(/obj/item/clothing/head/bomb_hood)

/datum/export/gear/bombsuit
	cost = 60
	unit_name = "bomb suit"
	export_types = list(/obj/item/clothing/suit/bomb_suit)

//--------------------------------------------
//---------------GLASSES----------------------
//--------------------------------------------

/datum/export/gear/glasses
	cost = 1
	include_subtypes = FALSE
	unit_name = "glasses"
	export_types = list(/obj/item/clothing/glasses)

/datum/export/gear/glasses/hud
	cost = 5
	include_subtypes = TRUE
	unit_name = "hud glasses"
	export_types = list(/obj/item/clothing/glasses/hud)

/datum/export/gear/glasses/meson
	cost = 10
	unit_name = "meson glasses"
	export_types = list(/obj/item/clothing/glasses/meson)

/datum/export/gear/glasses/night
	cost = 40
	unit_name = "night vision glasses"
	export_types = list(/obj/item/clothing/glasses/night)

/datum/export/gear/glasses/thermal
	cost = 80
	include_subtypes = TRUE
	unit_name = "thermal vision glasses"
	export_types = list(/obj/item/clothing/glasses/thermal)

/datum/export/gear/glasses/welding
	cost = 10
	include_subtypes = TRUE
	unit_name = "welding glasses"
	export_types = list(/obj/item/clothing/glasses/welding)


//--------------------------------------------
//----------------SHOES-----------------------
//--------------------------------------------

/datum/export/gear/shoes/combat
	cost = 40
	unit_name = "combat boots"
	export_types = list(/obj/item/clothing/shoes/boots/combat,
									/obj/item/clothing/shoes/boots/swat)

/datum/export/gear/shoes/jackboots
	cost = 2
	unit_name = "jackboots"
	export_types = list(/obj/item/clothing/shoes/boots)

/datum/export/gear/shoes/magboots
	cost = 5
	unit_name = "magboots"
	export_types = list(/obj/item/clothing/shoes/magboots)

/datum/export/gear/shoes/rainbow
	cost = 5
	unit_name = "rainbow shoes"
	export_types = list(/obj/item/clothing/shoes/rainbow)
