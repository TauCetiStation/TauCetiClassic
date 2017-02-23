/obj/item/clothing/head/helmet/space/sk
	name = "Skafandr Kosmicheskiy Helmet"
	desc = "SK-1 Spacesuit helmet. The first spacesuit helmet ever used. Reminds you of Vostok spaceflight and Yuri Gagarin"
	icon_state = "sk"
	item_state = "sk"
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	siemens_coefficient = 0.65
	species_restricted = list("exclude","Diona","Vox")

/obj/item/clothing/suit/space/sk
	name = "Skafandr Kosmicheskiy"
	icon_state = "sk"
	item_state = "sk"
	desc = "SK-1 Spacesuit. The first spacesuit ever used. Reminds you of Vostok spaceflight and Yuri Gagarin"
	flags_pressure = STOPS_LOWPRESSUREDMAGE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	slowdown = 4
	siemens_coefficient = 0.65

/obj/item/clothing/suit/space/sk/equipped()
	..()
	SSobj.processing |= src

/obj/item/clothing/suit/space/sk/dropped()
	..()
	SSobj.processing.Remove(src)

/obj/item/clothing/suit/space/sk/process()
	if(istype(get_turf(src), /turf/space) && !istype(loc.loc, /obj/mecha))
		create_breaches(BRUTE,2.3)