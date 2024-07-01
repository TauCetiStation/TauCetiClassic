var/global/list/event_cryopods = list()

/obj/machinery/cryopod_event
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "cryosleeper_cl"
	density = TRUE
	anchored = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE

/obj/machinery/cryopod_event/New(loc)
	..()
	event_cryopods += loc
