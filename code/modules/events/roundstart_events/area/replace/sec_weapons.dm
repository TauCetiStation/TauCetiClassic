/datum/event/roundstart/area/replace/sec_weapons
	special_area_types = list(/area/station/security/warden, /area/station/security/armoury)
	random_replaceable_types = list(/obj/item/weapon/gun, /obj/item/ammo_box, /obj/item/clothing/head, /obj/item/clothing/suit)

/datum/event/roundstart/area/replace/sec_weapons/setup()
	. = ..()
	replace_types[find_replaceable_type()] = null
