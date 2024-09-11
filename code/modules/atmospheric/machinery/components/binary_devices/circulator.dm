//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator"
	desc = "A gas circulator turbine and heat exchanger."
	icon = 'icons/obj/machines/power/thermoelectric.dmi'
	icon_state = "circ-unassembled-0"

	anchored = FALSE
	density = TRUE

	var/recent_moles_transferred = 0
	var/last_pressure_delta = 0
	var/last_worldtime_transfer = 0

	var/flipped = 0
	var/obj/machinery/power/generator/gen = null

/obj/machinery/atmospherics/components/binary/circulator/atom_init()
	. = ..()

	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."

	var/datum/gas_mixture/air1 = AIR1
	air1.volume = 400

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/circulator(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)

/obj/machinery/atmospherics/components/binary/circulator/proc/return_transfer_air()
	var/datum/gas_mixture/transfered
	if(anchored && !(stat & BROKEN))

		var/datum/gas_mixture/air1 = AIR1
		var/datum/gas_mixture/air2 = AIR2

		last_pressure_delta = max(air1.return_pressure() - air2.return_pressure() - 5, 0)

		//only circulate air if there is a pressure difference (plus 5kPa kinetic, 10kPa static friction)
		if(air1.temperature > 0 && last_pressure_delta > 5)
			var/datum/pipeline/parent1 = PARENT1
			//Calculate necessary moles to transfer using PV = nRT
			recent_moles_transferred = (last_pressure_delta * parent1.air.volume / (air1.temperature * R_IDEAL_GAS_EQUATION)) / 3 //uses the volume of the whole network, not just itself

			//Actually transfer the gas
			transfered = air1.remove(recent_moles_transferred)

			update_parents()

			last_worldtime_transfer = world.time
		else
			recent_moles_transferred = 0

		return transfered

/obj/machinery/atmospherics/components/binary/circulator/process_atmos()
	if(last_worldtime_transfer < world.time - 50)
		recent_moles_transferred = 0
	update_icon()

/obj/machinery/atmospherics/components/binary/circulator/update_icon()
	set_light(0, 0, null)
	cut_overlays()
	if(stat & BROKEN)
		icon_state = "circ-broken"
		return
	var/fd = flipped ? reverse_dir[dir] : dir
	if(panel_open)
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-panel", dir = fd))
	if(gen != null)
		icon_state = "circ-assembled-[flipped]"
	else
		icon_state = "circ-unassembled-[flipped]"

	if(!last_pressure_delta)
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-off"))
	else if(last_pressure_delta > 5 * ONE_ATMOSPHERE)
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-run"))
	else
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-slow"))

	var/datum/gas_mixture/air = AIR1
	var/heat = air.temperature * air.heat_capacity()

	if(heat == 0) //input gas mixture is empty/we have gas with zero heat capacity/we cooled gas to absolute zero. all of those options are excluded.
		return

	if(air.temperature <= 243) //-30C
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-cold", dir = fd))

		if(air.temperature <= 173) //-100C
			add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-excold", dir = fd))
			set_light(3, 5, "#0044ff")
		else
			set_light(1, 3, "#0044ff")


	else if(air.temperature >= 1773) //1500C
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-hot", dir = fd))

		if(air.temperature >= 4773) //4500C
			add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "circ-exhot", dir = fd))
			set_light(3, 5, "#ff0000")
		else
			set_light(1, 3, "#ff0000")

	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/attackby(obj/item/weapon/W, mob/user)
	if(iswrenching(W))
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
		if(PARENT1)
			nullifyPipenet(PARENT1)

		var/obj/machinery/atmospherics/node2 = NODE2

		if(node2)
			node2.disconnect(src)
			NODE2 = null
		if(PARENT2)
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

		if(gen)
			gen.reconnect()

	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), W))
		set_power_use(NO_POWER_USE)
		update_icon()
		return

	if(default_deconstruction_crowbar(W))
		return

	else
		..()

/obj/machinery/atmospherics/components/binary/circulator/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate Circulator (Clockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	set_dir(turn(src.dir, 90))
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."


/obj/machinery/atmospherics/components/binary/circulator/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate Circulator (Counterclockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	set_dir(turn(src.dir, -90))
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."

/obj/machinery/atmospherics/components/binary/circulator/verb/flip()
	set category = "Object"
	set name = "Flip Circulator"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	flipped = !flipped

	update_icon()

/obj/machinery/atmospherics/components/binary/circulator/can_be_node(obj/machinery/atmospherics/target)
	return anchored && ..() && (target.initialize_directions & initialize_directions)
