/obj/machinery/atmospherics/components/binary/valve/shutoff
	icon = 'icons/atmos/clamp.dmi'
	icon_state = "map_vclamp0"

	name = "automatic shutoff valve"
	desc = "A pipe valve. There is a reset button on the side."

	connect_types = CONNECT_TYPE_SCRUBBER | CONNECT_TYPE_SUPPLY | CONNECT_TYPE_REGULAR
	open = TRUE

	var/threshold = 101.15
	var/node1_last_pressure = 0
	var/node2_last_pressure = 0
	var/safe_counter = 0
	var/override_counter = 0

/obj/machinery/atmospherics/components/binary/valve/shutoff/update_icon()
	..()
	icon_state = "vclamp[open]"

/obj/machinery/atmospherics/components/binary/valve/shutoff/attack_hand(mob/user)
	if(..())
		return
	override_counter = 3

/obj/machinery/atmospherics/components/binary/valve/shutoff/process_atmos()
	last_flow_rate = 0
	last_power_draw = 0

	if(!NODE1 || !NODE2)
		return

	var/obj/machinery/atmospherics/node1 = NODE1
	var/obj/machinery/atmospherics/node2 = NODE2

	var/datum/gas_mixture/node1_air = node1.return_air()
	var/datum/gas_mixture/node2_air = node2.return_air()
	var/node1_pressure = node1_air.return_pressure()
	var/node2_pressure = node2_air.return_pressure()

	if(node1_last_pressure && node2_last_pressure && !override_counter)
		if(open)
			if(((node1_pressure <= threshold) || (node2_pressure <= threshold)) && (!((node1_pressure >= node1_last_pressure) && (node2_pressure >= node2_last_pressure)))) //I'm not proud of this line. /BlueNexus
				close(FALSE)
				safe_counter = 0
		else
			if((node1_pressure >= node1_last_pressure) && (node2_pressure >= node2_last_pressure))
				safe_counter++
			else
				safe_counter = 0
			if(safe_counter >= 6)
				open(FALSE)
				safe_counter = 0

	node1_last_pressure = node1_pressure
	node2_last_pressure = node2_pressure

	if(override_counter)
		override_counter--
