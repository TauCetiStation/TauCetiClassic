/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	layer = ABOVE_WINDOW_LAYER
	var/id = null
	var/active = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	layer = ABOVE_WINDOW_LAYER
	var/id = null
	var/active = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	layer = ABOVE_WINDOW_LAYER
	var/id = null
	var/active = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	req_access = list(access_crematorium)
	var/on = FALSE
	var/area/area = null
	var/otherarea = null
	var/id = 1

/obj/machinery/windowtint
	name = "window tint control"
	desc = "A remote control switch for polarized windows."
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	var/id = null
	var/active = FALSE
	var/range = 7

/obj/machinery/queue_button
	name = "queue next"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for a queue monitor."
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/queue_button/attack_hand()
	. = ..()
	if(.)
		flick("doorctrl-denied", src)
		return

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)
	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = "queue"
	frequency.post_signal(src, status_signal)

	flick("doorctrl1", src)
