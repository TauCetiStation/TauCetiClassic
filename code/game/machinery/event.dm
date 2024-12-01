var/global/list/event_cryopods = list()

/obj/machinery/event/cryopod
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "cryosleeper_cl"
	density = TRUE
	anchored = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE

/obj/machinery/event/cryopod/New(loc)
	..()
	event_cryopods += loc
