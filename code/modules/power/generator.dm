
/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "Generator able to produce power using difference of temperatures in nearby circulators."
	icon = 'icons/obj/machines/power/thermoelectric.dmi'
	icon_state = "teg-unassembled"
	density = TRUE
	anchored = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/obj/machinery/atmospherics/components/binary/circulator/circ1
	var/obj/machinery/atmospherics/components/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

	var/efficiency = 0.3 //how much heat is converted into energy

/obj/machinery/power/generator/atom_init()
	..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teg(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)

	var/cap_rating = 0
	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/capacitor))
			cap_rating += P.rating
	efficiency = efficiency * ((cap_rating / 3) * 0.15)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/generator/atom_init_late()
	reconnect()

/obj/machinery/power/generator/proc/is_facing_gen(obj/machinery/atmospherics/components/binary/circulator/C, rd)
	. = FALSE
	var/gd = src.dir
	var/cd = C.dir
	var/f = C.flipped
	if(gd & (EAST|WEST))
		if(rd & WEST)
			if((cd & NORTH) && !f)
				return TRUE
			else if((cd & SOUTH) && f)
				return TRUE

		else if(rd & EAST)
			if((cd & NORTH) && f)
				return TRUE
			else if((cd & SOUTH) && !f)
				return TRUE
	else if(gd & (NORTH|SOUTH))
		if(rd & NORTH)
			if((cd & EAST) && !f)
				return TRUE
			else if((cd & WEST) && f)
				return TRUE

		else if(rd & SOUTH)
			if((cd & EAST) && f)
				return TRUE
			else if((cd & WEST) && !f)
				return TRUE


//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/generator/proc/reconnect()
	if(circ1 && circ2)
		circ1.gen = null
		circ1.update_icon()
		circ2.gen = null
		circ2.update_icon()

	circ1 = null
	circ2 = null
	anchored ? connect_to_network() : disconnect_from_network()
	if(src.loc && anchored)
		power_change()
		if(src.dir & (EAST|WEST))
			circ1 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,EAST)
			circ2 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,WEST)

			if(circ1 && circ2)
				if((!is_facing_gen(circ1, EAST) || !circ1.anchored || circ1.panel_open)  || (!is_facing_gen(circ2, WEST) || !circ2.anchored || circ2.panel_open))
					circ1 = null
					circ2 = null

		else if(src.dir & (NORTH|SOUTH))
			circ1 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,NORTH)
			circ2 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,SOUTH)

			if(circ1 && circ2)
				if((!is_facing_gen(circ1, NORTH) || !circ1.anchored || circ1.panel_open)  || (!is_facing_gen(circ2, SOUTH) || !circ2.anchored || circ2.panel_open))
					circ1 = null
					circ2 = null

	if(circ1 && circ2)
		circ1.gen = src
		circ1.update_icon()
		circ2.gen = src
		circ2.update_icon()

	update_icon()

/obj/machinery/power/generator/update_icon()
	cut_overlays()
	if(stat & BROKEN)
		icon_state = "teg-broken"
		return
	if(panel_open && !(circ1 && circ2 && anchored))
		add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "teg-panel"))

	if(circ1 && circ2 && anchored)
		icon_state = "teg-assembled"
	else
		icon_state = "teg-unassembled"

	if(!(stat & (NOPOWER|BROKEN)))
		if(lastgenlev != 0)
			add_overlay(image("icons/obj/machines/power/thermoelectric.dmi", "teg-op[lastgenlev]"))

/obj/machinery/power/generator/process()
	if(!circ1 || !circ2 || !anchored || stat & (BROKEN|NOPOWER))
		return

	updateDialog()

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()
	lastgen = 0

	if(air1 && air2)
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/energy_transfer = delta_temperature*air2_heat_capacity*air1_heat_capacity/(air2_heat_capacity+air1_heat_capacity)
			var/heat = energy_transfer*(1-efficiency)*2
			lastgen = energy_transfer*efficiency

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity

			//Transfer the air
			var/datum/gas_mixture/circ1_air2 = circ1.AIR2
			var/datum/gas_mixture/circ2_air2 = circ2.AIR2

			circ1_air2.merge(air1)
			circ2_air2.merge(air2)

			//Update the gas networks
			var/datum/pipeline/parent1 = circ1.PARENT1
			var/datum/pipeline/parent2 = circ2.PARENT2

			parent1.update = 1
			parent2.update = 1

	// update icon overlays and power usage only if displayed level has changed
	if(lastgen > 250000 && prob(10))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		lastgen *= 0.5
	var/genlev = max(0, min( round(11*lastgen / 250000), 11))
	if(lastgen > 100 && genlev == 0)
		genlev = 1
	if(genlev != lastgenlev)
		lastgenlev = genlev
		update_icon()
	add_avail(lastgen)

/obj/machinery/power/generator/attackby(obj/item/weapon/W, mob/user)
	if(iswrenching(W))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.</span>")
		lastgenlev = 0
		reconnect()
		update_icon()
	else
		..()

	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), W))
		set_power_use(NO_POWER_USE)
		update_icon()
		return

	if(default_deconstruction_crowbar(W))
		return

/obj/machinery/power/generator/interact(mob/user)
	if(anchored)
		..()

/obj/machinery/power/generator/ui_interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && !(issilicon(user) || isobserver(user)))
		user.unset_machine(src)
		user << browse(null, "window=teg")
		return

	var/t = "<PRE><B>Thermo-Electric Generator</B><HR>"

	if(circ1 && circ2)
		var/datum/gas_mixture/circ1_air1 = circ1.AIR1
		var/datum/gas_mixture/circ1_air2 = circ1.AIR2
		var/datum/gas_mixture/circ2_air1 = circ2.AIR1
		var/datum/gas_mixture/circ2_air2 = circ2.AIR2

		t += "Output : [round(lastgen)] W<BR><BR>"

		t += "<B>Primary Circulator (top or right)</B><BR>"

		t += "Inlet Pressure: [round(circ1_air1.return_pressure(), 0.1)] kPa<BR>"
		t += "Inlet Temperature: [round(circ1_air1.temperature, 0.1)] K<BR>"
		t += "Outlet Pressure: [round(circ1_air2.return_pressure(), 0.1)] kPa<BR>"
		t += "Outlet Temperature: [round(circ1_air2.temperature, 0.1)] K<BR>"

		t += "<B>Secondary Circulator (bottom or left)</B><BR>"
		t += "Inlet Pressure: [round(circ2_air1.return_pressure(), 0.1)] kPa<BR>"
		t += "Inlet Temperature: [round(circ2_air1.temperature, 0.1)] K<BR>"
		t += "Outlet Pressure: [round(circ2_air2.return_pressure(), 0.1)] kPa<BR>"
		t += "Outlet Temperature: [round(circ2_air2.temperature, 0.1)] K<BR>"

	else
		t += "Unable to connect to circulators.<br>"
		t += "Ensure both are in position and wrenched into place."

	t += "<BR>"
	t += "<HR>"
	t += "<A href='?src=\ref[src]'>Refresh</A>"

	var/datum/browser/popup = new(user, "teg", null, 460, 300)
	popup.set_content(t)
	popup.open()


/obj/machinery/power/generator/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	updateDialog()


/obj/machinery/power/generator/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	set_dir(turn(src.dir, 90))

/obj/machinery/power/generator/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.incapacitated() || anchored)
		return

	set_dir(turn(src.dir, -90))
