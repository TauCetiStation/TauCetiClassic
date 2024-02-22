/obj/machinery/bluespace_beacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	layer = 2.5
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	var/obj/item/device/radio/beacon/Beacon

/obj/machinery/bluespace_beacon/atom_init()
	. = ..()

	Beacon = new /obj/item/device/radio/beacon(src)

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, use_alpha = TRUE)

/obj/machinery/bluespace_beacon/Destroy()
	if(Beacon)
		qdel(Beacon)
	return ..()
