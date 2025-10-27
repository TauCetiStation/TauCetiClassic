/obj/item/clothing/head/helmet/space/sk
	name = "ERVOS helmet"
	desc = "Emergency Rescue VOid Suit helmet"
	icon_state = "ervos"
	item_state = "ervos_head"
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	siemens_coefficient = 0.65
	species_restricted = list("exclude" , DIONA)
	flash_protection = NONE
	flash_protection_slots = list()

/obj/item/clothing/suit/space/sk
	name = "ERVOS"
	icon_state = "ervos"
	item_state = "ervos"
	desc = "Emergency Rescue VOid Suit"
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	slowdown = 2
	siemens_coefficient = 0.65
	equip_time = 2 SECONDS

/obj/item/clothing/suit/space/sk/atom_init()
	. = ..()
	flags |= ONESIZEFITSALL

/obj/item/clothing/suit/space/sk/equipped()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/sk/dropped()
	..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/sk/process()
	if(isspaceturf(get_turf(src)) && !istype(loc.loc, /obj/mecha))
		create_breaches(BRUTE,2.3)
