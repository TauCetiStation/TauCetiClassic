/obj/machinery/door/airlock/alarmlock
	name = "glass alarm airlock"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	opacity = 0
	glass = 1

	var/datum/radio_frequency/air_connection
	var/air_frequency = 1437
	autoclose = 0

/obj/machinery/door/airlock/alarmlock/atom_init()
	. = ..()
	radio_controller.remove_object(src, air_frequency)
	air_connection = new
	air_connection = radio_controller.add_object(src, air_frequency, RADIO_TO_AIRALARM)
	INVOKE_ASYNC(src, PROC_REF(open))

/obj/machinery/door/airlock/alarmlock/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,air_frequency)
	return ..()

/obj/machinery/door/airlock/alarmlock/receive_signal(datum/signal/signal)
	..()
	if(stat & (NOPOWER|BROKEN))
		return

	var/alarm_area = signal.data["zone"]
	var/alert = signal.data["alert"]

	var/area/our_area = get_area(src)

	if(alarm_area == our_area.name)
		switch(alert)
			if("severe")
				autoclose = 1
				close()
			if("minor", "clear")
				autoclose = 0
				open()
