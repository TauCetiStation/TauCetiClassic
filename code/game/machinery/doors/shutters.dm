/obj/machinery/door/poddoor/shutters
	name = "Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	base_name = "shutter"
	icon_state = "shutter_closed"
	icon_state_open  = "shutter_opend"
	icon_state_close = "shutter_closed"
	door_open_sound  = 'sound/machines/shutter_open.ogg'
	door_close_sound = 'sound/machines/shutter_close.ogg'

/obj/machinery/door/poddoor/shutters/syndi
	var/open_allowed = FALSE

/obj/machinery/door/poddoor/shutters/syndi/open_checks(forced)
	return open_allowed

/obj/machinery/door/poddoor/shutters/syndi/emag_act(mob/user)
	return FALSE

/obj/machinery/door/poddoor/shutters/syndi/ex_act()
	return
