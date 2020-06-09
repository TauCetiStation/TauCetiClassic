/obj/item/clothing/head/helmet/space/sk
	name = "ERVOS helmet"
	desc = "Emergency Rescue VOid Suit helmet"
	icon_state = "ervos"
	item_state = "ervos_head"
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	siemens_coefficient = 0.65
	species_restricted = list("exclude" , DIONA , VOX)

/obj/item/clothing/suit/space/sk
	name = "ERVOS"
	icon_state = "ervos"
	item_state = "ervos"
	desc = "Emergency Rescue VOid Suit"
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	slowdown = 4
	siemens_coefficient = 0.65

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
	if(istype(get_turf(src), /turf/space) && !istype(loc.loc, /obj/mecha))
		create_breaches(BRUTE,2.3)
