
/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = 0
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/start_pressure = ONE_ATMOSPHERE
	var/maximum_pressure = 90*ONE_ATMOSPHERE

	New()
		..()

		air_contents.volume = volume
		air_contents.temperature = T20C

		return 1

	initialize()
		. = ..()
		spawn()
			var/obj/machinery/atmospherics/portables_connector/port = locate() in loc
			if(port)
				connect(port)
				update_icon()

	process()
		if(!connected_port) //only react when pipe_network will ont it do it for you
			//Allow for reactions
			air_contents.react()
		else
			update_icon()

	Destroy()
		qdel(air_contents)
		return ..()

	update_icon()
		return null

	proc

		StandardAirMix()
			return list(
				"oxygen" = O2STANDARD * MolesForPressure(),
				"nitrogen" = N2STANDARD *  MolesForPressure())

		MolesForPressure(var/target_pressure = start_pressure)
			return (target_pressure * air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

		connect(obj/machinery/atmospherics/portables_connector/new_port)
			//Make sure not already connected to something else
			if(connected_port || !new_port || new_port.connected_device)
				return 0

			//Make sure are close enough for a valid connection
			if(new_port.loc != loc)
				return 0

			//Perform the connection
			connected_port = new_port
			connected_port.connected_device = src

			anchored = 1 //Prevent movement

			//Actually enforce the air sharing
			var/datum/pipe_network/network = connected_port.return_network(src)
			if(network && !network.gases.Find(air_contents))
				network.gases += air_contents
				network.update = 1

			return 1

		disconnect()
			if(!connected_port)
				return 0

			var/datum/pipe_network/network = connected_port.return_network(src)
			if(network)
				network.gases -= air_contents

			anchored = 0

			connected_port.connected_device = null
			connected_port = null

			return 1

/obj/machinery/portable_atmospherics/attackby(obj/item/weapon/W, mob/user)
	//var/obj/icon = src
	if ((istype(W, /obj/item/weapon/tank) && !( src.destroyed )))
		if (src.holding)
			return
		var/obj/item/weapon/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
		update_icon()
		return

	else if (istype(W, /obj/item/weapon/wrench))
		if(connected_port)
			disconnect()
			to_chat(user, "\blue You disconnect [name] from the port.")
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					to_chat(user, "\blue You connect [name] to the port.")
					update_icon()
					return
				else
					to_chat(user, "\blue [name] failed to connect to the port.")
					return
			else
				to_chat(user, "\blue Nothing happens.")
				return

	else if ((istype(W, /obj/item/device/analyzer)) && Adjacent(user))
		var/obj/item/device/analyzer/A = W
		A.analyze_gases(src, user)
		return

	return
