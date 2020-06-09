#define ADIABATIC_EXPONENT 0.667 // Actually adiabatic exponent - 1.

/obj/machinery/atmospherics/components/pipeturbine
	name = "turbine"
	desc = "A gas turbine. Converting pressure into energy since 1884."
	icon = 'icons/obj/pipeturbine.dmi'
	icon_state = "turbine"
	anchored = 0
	density = 1

	var/efficiency = 0.4
	var/kin_energy = 0
	var/datum/gas_mixture/air_in = new
	var/datum/gas_mixture/air_out = new
	var/volume_ratio = 0.2
	var/kin_loss = 0.001

	var/dP = 0

/obj/machinery/atmospherics/components/pipeturbine/atom_init()
	. = ..()
	air_in.volume = 200
	air_out.volume = 800
	volume_ratio = air_in.volume / (air_in.volume + air_out.volume)

/obj/machinery/atmospherics/components/pipeturbine/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|WEST
		if(SOUTH)
			initialize_directions = EAST|WEST
		if(EAST)
			initialize_directions = NORTH|SOUTH
		if(WEST)
			initialize_directions = NORTH|SOUTH

/obj/machinery/atmospherics/components/pipeturbine/process_atmos()
	last_flow_rate = 0
	last_power_draw = 0

	if(anchored && !(stat & BROKEN))
		kin_energy *= 1 - kin_loss
		dP = max(air_in.return_pressure() - air_out.return_pressure(), 0)
		if(dP > 10)
			kin_energy += 1 / ADIABATIC_EXPONENT * dP * air_in.volume * (1 - volume_ratio ** ADIABATIC_EXPONENT) * efficiency
			air_in.temperature *= volume_ratio ** ADIABATIC_EXPONENT

			var/datum/gas_mixture/air_all = new
			air_all.volume = air_in.volume + air_out.volume
			air_all.merge(air_in.remove_ratio(1))
			air_all.merge(air_out.remove_ratio(1))

			air_in.merge(air_all.remove(volume_ratio))
			air_out.merge(air_all)

		update_icon()

	update_parents()

/obj/machinery/atmospherics/components/pipeturbine/update_icon()
	cut_overlays()
	if (dP > 10)
		add_overlay(image('icons/obj/pipeturbine.dmi', "moto-turb"))
	if (kin_energy > 100000)
		add_overlay(image('icons/obj/pipeturbine.dmi', "low-turb"))
	if (kin_energy > 500000)
		add_overlay(image('icons/obj/pipeturbine.dmi', "med-turb"))
	if (kin_energy > 1000000)
		add_overlay(image('icons/obj/pipeturbine.dmi', "hi-turb"))

/obj/machinery/atmospherics/components/pipeturbine/attackby(obj/item/weapon/W, mob/user)
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

/obj/machinery/atmospherics/components/pipeturbine/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate Circulator (Clockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	src.set_dir(turn(src.dir, -90))


/obj/machinery/atmospherics/components/pipeturbine/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate Circulator (Counterclockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	src.set_dir(turn(src.dir, 90))

/obj/machinery/power/turbinemotor
	name = "motor"
	desc = "Electrogenerator. Converts rotation into power."
	icon = 'icons/obj/pipeturbine.dmi'
	icon_state = "motor"
	anchored = 0
	density = 1

	var/kin_to_el_ratio = 0.1	//How much kinetic energy will be taken from turbine and converted into electricity
	var/obj/machinery/atmospherics/components/pipeturbine/turbine

/obj/machinery/power/turbinemotor/atom_init()
	. = ..()
	updateConnection()

/obj/machinery/power/turbinemotor/proc/updateConnection()
	turbine = null
	if(src.loc && anchored)
		turbine = locate(/obj/machinery/atmospherics/components/pipeturbine) in get_step(src,dir)
		if ((turbine.stat & BROKEN) || !turbine.anchored || turn(turbine.dir, 180) != dir)
			turbine = null

/obj/machinery/power/turbinemotor/process_atmos()
	updateConnection()
	if(!turbine || !anchored || (stat & BROKEN))
		return

	var/power_generated = kin_to_el_ratio * turbine.kin_energy
	turbine.kin_energy -= power_generated
	add_avail(power_generated)


/obj/machinery/power/turbinemotor/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		anchored = !anchored
		turbine = null
		to_chat(user, "<span class='notice'>You [anchored ? "secure" : "unsecure"] the bolts holding \the [src] to the floor.</span>")
		updateConnection()
	else
		..()

/obj/machinery/power/turbinemotor/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Motor Clockwise"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	set_dir(turn(dir, -90))

/obj/machinery/power/turbinemotor/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Motor Counterclockwise"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	set_dir(turn(dir, 90))
