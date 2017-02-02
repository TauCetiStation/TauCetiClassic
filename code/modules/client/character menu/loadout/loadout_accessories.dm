/datum/gear/accessory
	subtype_path = /datum/gear/accessory
	slot = slot_wear_mask
	sort_category = "Accessories"

/datum/gear/accessory/scarf
	display_name = "Scarf selection"
	path = /obj/item/clothing/mask/bluescarf

/datum/gear/accessory/scarf/New()
	..()
	var/scarfs = list()
	scarfs["blue"] = /obj/item/clothing/mask/bluescarf
	scarfs["red"] = /obj/item/clothing/mask/redscarf
	scarfs["green"] = /obj/item/clothing/mask/greenscarf
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

/datum/gear/accessory/bandana
	display_name = "Bandana"
	path = /obj/item/clothing/mask/bandana/red

/datum/gear/accessory/haircomb
	display_name = "Purple comb"
	path = /obj/item/weapon/haircomb

/datum/gear/accessory/lipstick
	display_name = "Lipstick selection"
	path = /obj/item/weapon/lipstick/black

/datum/gear/accessory/lipstick/New()
	..()
	var/lstiks = list()
	lstiks["jade"] = /obj/item/weapon/lipstick/jade
	lstiks["black"] = /obj/item/weapon/lipstick/black

	gear_tweaks += new/datum/gear_tweak/path(lstiks)

/datum/gear/accessory/fingerless
	display_name = "Fingerless gloves"
	path = /obj/item/clothing/gloves/fingerless

/datum/gear/accessory/left_black_glove
	display_name = "Left Black Glove"
	path = /obj/item/clothing/gloves/fluff/chal_appara_1