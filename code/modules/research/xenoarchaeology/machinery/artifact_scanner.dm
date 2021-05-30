
/obj/machinery/artifact_scanpad
	name = "Anomaly Scanner Pad"
	desc = "Place things here for scanning."
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "xenoarch_scanner"
	anchored = 1
	layer = INFRONT_MOB_LAYER
	density = 0

/obj/machinery/artifact_scanpad/atom_init()
	. = ..()
	var/image/I = image(icon, "xenoarch_scanner_bottom", ABOVE_NORMAL_TURF_LAYER)
	add_overlay(I)
