
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Miscellaneous xenoarchaeology tools

/obj/item/device/gps
	name = "relay positioning device"
	desc = "Triangulates the approximate co-ordinates using a nearby satellite network."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	item_state = "locator"
	w_class = ITEM_SIZE_SMALL

/obj/item/device/gps/attack_self(mob/user)
	var/turf/T = get_turf(src)
	to_chat(user, "<span class='notice'>[bicon(src)] [src] flashes <i>[T.x].[rand(0,9)]:[T.y].[rand(0,9)]:[T.z].[rand(0,9)]</i>.</span>")

/obj/item/device/measuring_tape
	name = "measuring tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "measuring"
	item_state = "measuring"
	w_class = ITEM_SIZE_SMALL

/obj/item/weapon/storage/bag/fossils
	name = "Fossil Satchel"
	desc = "Transports delicate fossils in suspension so they don't break during transit."
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "fossil_satchel"
	item_state = "fossil_satchel"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_POCKET
	w_class = ITEM_SIZE_NORMAL
	storage_slots = 50
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(
 		/obj/item/weapon/fossil,
 		/obj/item/weapon/ore/strangerock)
