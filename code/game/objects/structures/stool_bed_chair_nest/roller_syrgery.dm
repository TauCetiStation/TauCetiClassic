/*
 * Roller beds
 */
/obj/structure/stool/bed/roller/roller_surg
	name = "advanced roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	type_roller = /obj/item/roller/roller_holder_surg

/obj/item/roller/roller_holder_surg
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	type_bed = /obj/structure/stool/bed/roller/roller_surg



