/obj/machinery/atmospherics/components/unary/portables_connector
	icon = 'icons/atmos/connector.dmi'
	icon_state = "map_connector"

	name = "connector port"
	desc = "For connecting portable devices related to atmospherics control."

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	layer = GAS_FILTER_LAYER

	var/obj/machinery/portable_atmospherics/connected_device

/obj/machinery/atmospherics/components/unary/portables_connector/atom_init()
	. = ..()
	var/obj/machinery/portable_atmospherics/PA = locate() in loc
	if(PA)
		PA.connect(src)
		if(PA.initialized)
			PA.update_icon()

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/update_icon()
	..()
	icon_state = "connector"

/obj/machinery/atmospherics/components/unary/portables_connector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, dir)

/obj/machinery/atmospherics/components/unary/portables_connector/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	update_parents()

/obj/machinery/atmospherics/components/unary/portables_connector/can_unwrench(mob/user)
	if(..())
		if(connected_device)
			to_chat(user, "<span class='warning'>You cannot unwrench [src], detach [connected_device] first!</span>")
		else
			return TRUE

/obj/machinery/atmospherics/components/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
