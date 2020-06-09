/obj/machinery/bluespace_beacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = 2.5
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	var/obj/item/device/radio/beacon/Beacon

/obj/machinery/bluespace_beacon/atom_init()
	. = ..()
	var/turf/T = loc
	Beacon = new /obj/item/device/radio/beacon
	Beacon.invisibility = INVISIBILITY_MAXIMUM
	Beacon.loc = T

	hide(T.intact)

/obj/machinery/bluespace_beacon/Destroy()
	if(Beacon)
		qdel(Beacon)
	return ..()

// update the invisibility and icon
/obj/machinery/bluespace_beacon/hide(intact)
	invisibility = intact ? 101 : 0
	updateicon()

// update the icon_state
/obj/machinery/bluespace_beacon/proc/updateicon()
	var/state="floor_beacon"

	if(invisibility)
		icon_state = "[state]f"

	else
		icon_state = "[state]"

/obj/machinery/bluespace_beacon/process()
	if(!Beacon)
		var/turf/T = loc
		Beacon = new /obj/item/device/radio/beacon
		Beacon.invisibility = INVISIBILITY_MAXIMUM
		Beacon.loc = T
	if(Beacon)
		if(Beacon.loc != loc)
			Beacon.loc = loc

	updateicon()
