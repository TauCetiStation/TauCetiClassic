/obj/machinery/door/poddoor/shutters
	name = "Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"
	icon_state_open  = "shutter0"
	icon_state_close = "shutter1"
	door_open_sound  = 'sound/machines/shutter_open.ogg'
	door_close_sound = 'sound/machines/shutter_close.ogg'

/obj/machinery/door/poddoor/shutters/atom_init()
	. = ..()
	layer = SHUTTERS_LAYER

/obj/machinery/door/poddoor/shutters/do_animate(animation)
	switch(animation)
		if("opening")
			flick("shutterc0", src)
		if("closing")
			flick("shutterc1", src)
	return

/obj/machinery/door/poddoor/shutters/syndi

/obj/machinery/door/poddoor/shutters/syndi/emag_act(mob/user)
	return FALSE

/obj/machinery/door/poddoor/shutters/syndi/ex_act()
	return
