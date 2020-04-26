//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output

#define ADIABATIC_EXPONENT 0.667 //Actually adiabatic exponent - 1.

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator"
	desc = "A gas circulator turbine and heat exchanger."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "circ-off"

	anchored = FALSE
	density = TRUE

	var/kinetic_efficiency = 0.04 //combined kinetic and kinetic-to-electric efficiency
	var/volume_ratio = 0.2

	var/recent_moles_transferred = 0
	var/last_heat_capacity = 0
	var/last_temperature = 0
	var/last_pressure_delta = 0
	var/last_worldtime_transfer = 0
	var/last_stored_energy_transferred = 0
	var/volume_capacity_used = 0
	var/stored_energy = 0


/obj/machinery/atmospherics/components/binary/circulator/atom_init()
	. = ..()

	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."

	var/datum/gas_mixture/air1 = AIR1
	air1.volume = 400

/obj/machinery/atmospherics/components/binary/circulator/proc/return_transfer_air()
	var/datum/gas_mixture/removed
	if(anchored && !(stat & BROKEN))

		var/datum/gas_mixture/air1 = AIR1
		var/datum/gas_mixture/air2 = AIR2

		var/input_starting_pressure = air1.return_pressure()
		var/output_starting_pressure = air2.return_pressure()
		last_pressure_delta = max(input_starting_pressure - output_starting_pressure - 5, 0)

		//only circulate air if there is a pressure difference (plus 5kPa kinetic, 10kPa static friction)
		if(air1.temperature > 0 && last_pressure_delta > 5)
			var/datum/pipeline/parent1 = PARENT1
			//Calculate necessary moles to transfer using PV = nRT
			recent_moles_transferred = (last_pressure_delta * parent1.air.volume / (air1.temperature * R_IDEAL_GAS_EQUATION)) / 3 //uses the volume of the whole network, not just itself
			volume_capacity_used = min( (last_pressure_delta * parent1.air.volume / 3) / (input_starting_pressure * air1.volume) , 1) //how much of the gas in the input air volume is consumed

			//Calculate energy generated from kinetic turbine
			stored_energy += 1 / ADIABATIC_EXPONENT * min(last_pressure_delta * parent1.air.volume , input_starting_pressure*air1.volume) * (1 - volume_ratio ** ADIABATIC_EXPONENT) * kinetic_efficiency

			//Actually transfer the gas
			removed = air1.remove(recent_moles_transferred)
			if(removed)
				last_heat_capacity = removed.heat_capacity()
				last_temperature = removed.temperature

				update_parents()

				last_worldtime_transfer = world.time
		else
			recent_moles_transferred = 0

		update_icon()
		return removed

/obj/machinery/atmospherics/components/binary/circulator/proc/return_stored_energy()
	last_stored_energy_transferred = stored_energy
	stored_energy = 0
	return last_stored_energy_transferred

/obj/machinery/atmospherics/components/binary/circulator/process_atmos()
	if(last_worldtime_transfer < world.time - 50)
		recent_moles_transferred = 0
		update_icon()

/obj/machinery/atmospherics/components/binary/circulator/update_icon()
	if(stat & (BROKEN|NOPOWER) || !anchored)
		icon_state = "circ-p"
	else if(last_pressure_delta > 0 && recent_moles_transferred > 0)
		if(last_pressure_delta > 5 * ONE_ATMOSPHERE)
			icon_state = "circ-run"
		else
			icon_state = "circ-slow"
	else
		icon_state = "circ-off"

	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		user.visible_message(
			"[user.name] [anchored ? "secures" : "unsecures"] the bolts holding [src.name] to the floor.", \
			"You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.", \
			"You hear a ratchet")

		SetInitDirections()
		var/obj/machinery/atmospherics/node1 = NODE1
		if(node1)
			node1.disconnect(src)
			NODE1 = null
		nullifyPipenet(PARENT1)

		var/obj/machinery/atmospherics/node2 = NODE2
		if(node2)
			node2.disconnect(src)
			NODE2 = null
		nullifyPipenet(PARENT2)

		if(anchored)
			atmos_init()

			node1 = NODE1
			node2 = NODE2

			if(node1)
				node1.atmos_init()
				node1.addMember(src)
			if(node2)
				node2.atmos_init()
				node2.addMember(src)

			build_network()

	else
		..()

/obj/machinery/atmospherics/components/binary/circulator/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate Circulator (Clockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	src.set_dir(turn(src.dir, 90))
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."


/obj/machinery/atmospherics/components/binary/circulator/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate Circulator (Counterclockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	src.set_dir(turn(src.dir, -90))
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."
