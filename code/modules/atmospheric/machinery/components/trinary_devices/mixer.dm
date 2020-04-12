/obj/machinery/atmospherics/components/trinary/mixer
	icon = 'icons/atmos/mixer.dmi'
	icon_state = "map"
	density = FALSE

	name = "gas mixer"

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 150 // internal circuitry, friction losses and stuff
	power_rating = 3700    // This also doubles as a measure of how powerful the mixer is, in Watts. 3700 W ~ 5 HP
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_MIXER
	var/list/mixing_inputs

	//for mapping
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	//node 3 is the outlet, nodes 1 & 2 are intakes

/obj/machinery/atmospherics/components/trinary/mixer/on
	icon_state = "map_on"
	use_power = IDLE_POWER_USE

/obj/machinery/atmospherics/components/trinary/mixer/update_icon(safety = FALSE)
	..()
	if(istype(src, /obj/machinery/atmospherics/components/trinary/mixer/m_mixer))
		icon_state = "m"
	else if(istype(src, /obj/machinery/atmospherics/components/trinary/mixer/t_mixer))
		icon_state = "t"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(NODE1 && NODE2 && NODE3)
		icon_state += use_power ? "on" : "off"
	else
		icon_state += "off"
		set_power_use(NO_POWER_USE)

/obj/machinery/atmospherics/components/trinary/mixer/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		if(istype(src, /obj/machinery/atmospherics/components/trinary/mixer/t_mixer))
			add_underlay(T, NODE1, turn(dir, -90))
		else
			add_underlay(T, NODE1, turn(dir, -180))

		if(istype(src, /obj/machinery/atmospherics/components/trinary/mixer/m_mixer) || istype(src, /obj/machinery/atmospherics/components/trinary/mixer/t_mixer))
			add_underlay(T, NODE2, turn(dir, 90))
		else
			add_underlay(T, NODE2, turn(dir, -90))

		add_underlay(T, NODE3, dir)

/obj/machinery/atmospherics/components/trinary/mixer/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/trinary/mixer/atom_init()
	. = ..()

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2
	var/datum/gas_mixture/air3 = AIR3

	air1.volume = ATMOS_DEFAULT_VOLUME_MIXER
	air2.volume = ATMOS_DEFAULT_VOLUME_MIXER
	air3.volume = ATMOS_DEFAULT_VOLUME_MIXER * 1.5

	if (!mixing_inputs)
		mixing_inputs = list(AIR1 = node1_concentration, AIR2 = node2_concentration)

/obj/machinery/atmospherics/components/trinary/mixer/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return
	if(!(NODE1 && NODE2 && NODE3))
		return

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2
	var/datum/gas_mixture/air3 = AIR3

	//Figure out the amount of moles to transfer
	var/transfer_moles = (set_flow_rate * mixing_inputs[air1] / air1.volume) * air1.total_moles + (set_flow_rate * mixing_inputs[air1] / air2.volume) * air2.total_moles

	var/power_draw = -1
	if (transfer_moles > MINIMUM_MOLES_TO_FILTER)
		power_draw = mix_gas(src, mixing_inputs, air3, transfer_moles, power_rating)

		if(PARENT1 && mixing_inputs[air1])
			var/datum/pipeline/parent1 = PARENT1
			parent1.update = TRUE

		if(PARENT2 && mixing_inputs[air2])
			var/datum/pipeline/parent2 = PARENT2
			parent2.update = TRUE

		if(PARENT3)
			var/datum/pipeline/parent3 = PARENT3
			parent3.update = TRUE

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

/obj/machinery/atmospherics/components/trinary/mixer/ui_interact(user)
	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[use_power?"On":"Off"]</a><br>
				<b>Set Flow Rate Limit: </b>
				[set_flow_rate]L/s | <a href='?src=\ref[src];set_press=1'>Change</a>
				<br>
				<b>Flow Rate: </b>[round(last_flow_rate, 0.1)]L/s
				<br><hr>
				<b>Node 1 Concentration:</b>
				<a href='?src=\ref[src];node1_c=-0.1'><b>-</b></a>
				<a href='?src=\ref[src];node1_c=-0.01'>-</a>
				[mixing_inputs[air1]]([mixing_inputs[air1]*100]%)
				<a href='?src=\ref[src];node1_c=0.01'><b>+</b></a>
				<a href='?src=\ref[src];node1_c=0.1'>+</a>
				<br>
				<b>Node 2 Concentration:</b>
				<a href='?src=\ref[src];node2_c=-0.1'><b>-</b></a>
				<a href='?src=\ref[src];node2_c=-0.01'>-</a>
				[mixing_inputs[air2]]([mixing_inputs[air2]*100]%)
				<a href='?src=\ref[src];node2_c=0.01'><b>+</b></a>
				<a href='?src=\ref[src];node2_c=0.1'>+</a>
				"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_mixer")
	onclose(user, "atmo_mixer")

/obj/machinery/atmospherics/components/trinary/mixer/Topic(href, href_list)
	if(!..())
		return FALSE

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	if(href_list["power"])
		use_power = !use_power
	if(href_list["set_press"])
		var/max_flow_rate = min(air1.volume, air2.volume)
		var/new_flow_rate = input(usr,"Enter new flow rate limit (0-[max_flow_rate]L/s)","Flow Rate Control", set_flow_rate) as num
		set_flow_rate = max(0, min(max_flow_rate, new_flow_rate))
	if(href_list["node1_c"])
		var/value = text2num(href_list["node1_c"])
		mixing_inputs[air1] = max(0, min(1, mixing_inputs[air1] + value))
		mixing_inputs[air2] = 1.0 - mixing_inputs[air1]
	if(href_list["node2_c"])
		var/value = text2num(href_list["node2_c"])
		mixing_inputs[air2] = max(0, min(1, mixing_inputs[air2] + value))
		mixing_inputs[air1] = 1.0 - mixing_inputs[air2]

	update_icon()
	updateUsrDialog()

/obj/machinery/atmospherics/components/trinary/mixer/t_mixer
	icon_state = "tmap"
	initialize_directions = SOUTH|EAST|WEST

	//node 3 is the outlet, nodes 1 & 2 are intakes

/obj/machinery/atmospherics/components/trinary/mixer/t_mixer/on
	icon_state = "tmap_on"
	use_power = IDLE_POWER_USE

/obj/machinery/atmospherics/components/trinary/mixer/t_mixer/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|NORTH|WEST
		if(SOUTH)
			initialize_directions = SOUTH|WEST|EAST
		if(EAST)
			initialize_directions = EAST|NORTH|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|SOUTH

/obj/machinery/atmospherics/components/trinary/mixer/m_mixer
	icon_state = "mmap"
	initialize_directions = SOUTH|NORTH|EAST

	//node 3 is the outlet, nodes 1 & 2 are intakes

/obj/machinery/atmospherics/components/trinary/mixer/m_mixer/on
	icon_state = "mmap_on"
	use_power = IDLE_POWER_USE

/obj/machinery/atmospherics/components/trinary/mixer/m_mixer/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = WEST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|EAST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|NORTH
		if(WEST)
			initialize_directions = WEST|SOUTH|EAST
