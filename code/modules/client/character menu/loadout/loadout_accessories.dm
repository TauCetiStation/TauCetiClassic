/datum/gear/accessory
	subtype_path = /datum/gear/accessory
	slot = SLOT_WEAR_MASK
	sort_category = "Accessories"

/datum/gear/accessory/scarf
	display_name = "Scarf selection"
	path = /obj/item/clothing/mask/scarf/blue

/datum/gear/accessory/scarf/New()
	..()
	var/scarfs = list()
	scarfs["blue"] = /obj/item/clothing/mask/scarf/blue
	scarfs["red"] = /obj/item/clothing/mask/scarf/red
	scarfs["green"] = /obj/item/clothing/mask/scarf/green
	scarfs["yellow"] = /obj/item/clothing/mask/scarf/yellow
	scarfs["violet"] = /obj/item/clothing/mask/scarf/violet
	gear_tweaks += new/datum/gear_tweak/path(scarfs)

/datum/gear/accessory/headwear
	display_name = "Skrell headwear selection"
	path = /obj/item/clothing/head/skrell_headwear

/datum/gear/accessory/headwear/New()
	..()
	var/headwear = list()
	headwear["yellow"] = /obj/item/clothing/head/skrell_headwear
	headwear["red"] = /obj/item/clothing/head/skrell_headwear/red
	headwear["blue"] = /obj/item/clothing/head/skrell_headwear/blue
	gear_tweaks += new/datum/gear_tweak/path(headwear)


/datum/gear/accessory/headscarf
	display_name = "Zhan Headscarf"
	path = /obj/item/clothing/head/headscarf

/datum/gear/accessory/haircomb
	display_name = "Purple comb"
	path = /obj/item/weapon/haircomb

/datum/gear/accessory/lipstick
	display_name = "Lipstick selection"
	path = /obj/item/weapon/lipstick

/datum/gear/accessory/lipstick/New()
	..()
	var/lstiks = list()
	lstiks["red"] = /obj/item/weapon/lipstick
	lstiks["purple"] = /obj/item/weapon/lipstick/purple
	lstiks["jade"] = /obj/item/weapon/lipstick/jade
	lstiks["black"] = /obj/item/weapon/lipstick/black

	gear_tweaks += new/datum/gear_tweak/path(lstiks)

/datum/gear/accessory/tie
	display_name = "Tie selection"
	path = /obj/item/clothing/accessory/tie

/datum/gear/accessory/tie/New()
	..()
	var/tie = list()
	tie["blue"] = /obj/item/clothing/accessory/tie/blue
	tie["red"] = /obj/item/clothing/accessory/tie/red
	tie["horrible"] = /obj/item/clothing/accessory/tie/horrible
	gear_tweaks += new/datum/gear_tweak/path(tie)

/datum/gear/accessory/armband
	display_name = "Armband selection"
	path = /obj/item/clothing/accessory/armband
	allowed_roles = list("Security Officer", "Security Cadet", "Warden", "Detective", "Head of Security", "Forensic Technician" )

/datum/gear/accessory/armband/New()
	..()
	var/armbands = list()
	armbands["red"] = /obj/item/clothing/accessory/armband
	armbands["cargo"] = /obj/item/clothing/accessory/armband/cargo
	armbands["engine"] = /obj/item/clothing/accessory/armband/engine
	armbands["science"] = /obj/item/clothing/accessory/armband/science
	armbands["hydro"] = /obj/item/clothing/accessory/armband/hydro
	armbands["med"] = /obj/item/clothing/accessory/armband/med
	armbands["medgreen"] = /obj/item/clothing/accessory/armband/medgreen
	gear_tweaks += new/datum/gear_tweak/path(armbands)

/datum/gear/accessory/fingerless
	display_name = "Fingerless gloves"
	path = /obj/item/clothing/gloves/fingerless

/datum/gear/accessory/left_black_glove
	display_name = "Left Black Glove"
	path = /obj/item/clothing/gloves/fluff/chal_appara_1

/datum/gear/accessory/silver_collar
	display_name = "Silver Collar"
	path = /obj/item/clothing/mask/tie/collar

/datum/gear/accessory/gold_collar
	display_name = "Gold Collar"
	path = /obj/item/clothing/mask/tie/collar2

/datum/gear/accessory/metal_cross
	display_name = "Metal cross"
	path = /obj/item/clothing/accessory/metal_cross

/datum/gear/accessory/bronze_cross
	display_name = "Bronze cross"
	path = /obj/item/clothing/accessory/bronze_cross
	cost = 2
