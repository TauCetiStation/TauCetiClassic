/datum/gear/head
	display_name = "Top hat"
	path = /obj/item/clothing/head/that
	slot = SLOT_HEAD
	sort_category = "Hats and Headwear"

/datum/gear/head/cap
	display_name = "Cap selection"
	path = /obj/item/clothing/head/soft

/datum/gear/head/cap/New()
	..()
	var/colors = list()
	colors["red"] = /obj/item/clothing/head/soft/red
	colors["blue"] = /obj/item/clothing/head/soft/blue
	colors["green"] = /obj/item/clothing/head/soft/green
	colors["yellow"] = /obj/item/clothing/head/soft/yellow
	colors["grey"] = /obj/item/clothing/head/soft/grey
	colors["orange"] = /obj/item/clothing/head/soft/orange
	colors["purple"] = /obj/item/clothing/head/soft/purple
	colors["rainbow"] = /obj/item/clothing/head/soft/rainbow
	gear_tweaks += new/datum/gear_tweak/path(colors)

/datum/gear/head/bandana
	display_name = "Bandana selection"
	path = /obj/item/clothing/head/bandana

/datum/gear/head/bandana/New()
	..()
	var/bandanas = list()
	bandanas["red"] = /obj/item/clothing/mask/bandana/red
	bandanas["blue"] = /obj/item/clothing/mask/bandana/blue
	bandanas["green"] = /obj/item/clothing/mask/bandana/green
	bandanas["gold"] = /obj/item/clothing/mask/bandana/gold
	bandanas["black"] = /obj/item/clothing/mask/bandana/black
	bandanas["orange"] = /obj/item/clothing/head/helmet/greenbandana/fluff/taryn_kifer_1
	gear_tweaks += new/datum/gear_tweak/path(bandanas)

/datum/gear/head/flatcap
	display_name = "Flat cap"
	path = /obj/item/clothing/head/flatcap

/datum/gear/head/bowler
	display_name = "Bowler hat"
	path = /obj/item/clothing/head/bowler

/datum/gear/head/fedora
	display_name = "Fedora"
	path = /obj/item/clothing/head/fedora

/datum/gear/head/orangebandana
	display_name = "Orange bandana"
	path = /obj/item/clothing/head/helmet/greenbandana/fluff/taryn_kifer_1

/datum/gear/head/fez
	display_name =  "Fez"
	path = /obj/item/clothing/head/fez

/datum/gear/head/indiana
	display_name = "Leather hat"
	path = /obj/item/clothing/head/indiana

/datum/gear/head/cowboy
	display_name = "Cowboy hat"
	path = /obj/item/clothing/head/western/cowboy

/datum/gear/head/kung
	display_name = "Kung bandana"
	path = /obj/item/clothing/head/det_hat/fluff/kung
	cost = 1

/datum/gear/head/black_hood
	display_name = "Black hood"
	path = /obj/item/clothing/head/black_hood

/datum/gear/head/beret
	display_name = "Beret selection"
	path = /obj/item/clothing/head/beret

/datum/gear/head/beret/New()
	..()
	var/berets = list()
	berets["red"] = /obj/item/clothing/head/beret/red
	berets["blue"] = /obj/item/clothing/head/beret/blue
	berets["black"] = /obj/item/clothing/head/beret/black
	berets["purple"] = /obj/item/clothing/head/beret/purple
	gear_tweaks += new/datum/gear_tweak/path(berets)
