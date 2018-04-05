/obj/machinery/atmospherics/components/trinary/filter
	icon = 'icons/atmos/filter.dmi'
	icon_state = "map"
	density = FALSE

	name = "gas filter"

	can_unwrench = TRUE
	use_power = 0
	idle_power_usage = 150 // internal circuitry, friction losses and stuff
	power_rating = 7500    // This also doubles as a measure of how powerful the filter is, in Watts. 7500 W ~ 10 HP
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_FILTER

	/*
	Filter types:
	-1: Nothing
	 0: Phoron: Phoron, Oxygen Agent B
	 1: Oxygen: Oxygen ONLY
	 2: Nitrogen: Nitrogen ONLY
	 3: Carbon Dioxide: Carbon Dioxide ONLY
	 4: Sleeping Agent (N2O)
	*/
	var/filter_type = -1
	var/list/filtered_out = list()


	frequency = 0

/obj/machinery/atmospherics/components/trinary/filter/on
	icon_state = "map_on"
	use_power = 1

/obj/machinery/atmospherics/components/trinary/filter/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/trinary/filter/atom_init()
	. = ..()
	switch(filter_type)
		if(0) //removing hydrocarbons
			filtered_out = list("phoron")
		if(1) //removing O2
			filtered_out = list("oxygen")
		if(2) //removing N2
			filtered_out = list("nitrogen")
		if(3) //removing CO2
			filtered_out = list("carbon_dioxide")
		if(4)//removing N2O
			filtered_out = list("sleeping_agent")

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2
	var/datum/gas_mixture/air3 = AIR3

	air1.volume = ATMOS_DEFAULT_VOLUME_FILTER
	air2.volume = ATMOS_DEFAULT_VOLUME_FILTER
	air3.volume = ATMOS_DEFAULT_VOLUME_FILTER

/obj/machinery/atmospherics/components/trinary/filter/update_icon()
	if(istype(src, /obj/machinery/atmospherics/components/trinary/filter/m_filter))
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(NODE2 && NODE3 && NODE1)
		icon_state += use_power ? "on" : "off"
	else
		icon_state += "off"
		use_power = 0

/obj/machinery/atmospherics/components/trinary/filter/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, NODE1, turn(dir, -180))

		if(istype(src, /obj/machinery/atmospherics/components/trinary/filter/m_filter))
			add_underlay(T, NODE2, turn(dir, 90))
		else
			add_underlay(T, NODE2, turn(dir, -90))

		add_underlay(T, NODE3, dir)

/obj/machinery/atmospherics/components/trinary/filter/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/trinary/filter/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return
	if(!(NODE1 && NODE2 && NODE3))
		return 0

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2
	var/datum/gas_mixture/air3 = AIR3

	//Figure out the amount of moles to transfer
	var/transfer_moles = (set_flow_rate / air1.volume) * air1.total_moles

	var/power_draw = -1
	if (transfer_moles > MINIMUM_MOLES_TO_FILTER)
		power_draw = filter_gas(src, filtered_out, air1, air2, air3, transfer_moles, power_rating)

		update_parents()

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

/obj/machinery/atmospherics/components/trinary/filter/atmos_init()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/components/trinary/filter/ui_interact(user) // -- TLE
	var/dat
	var/current_filter_type
	switch(filter_type)
		if(0)
			current_filter_type = "Phoron"
		if(1)
			current_filter_type = "Oxygen"
		if(2)
			current_filter_type = "Nitrogen"
		if(3)
			current_filter_type = "Carbon Dioxide"
		if(4)
			current_filter_type = "Nitrous Oxide"
		if(-1)
			current_filter_type = "Nothing"
		else
			current_filter_type = "ERROR - Report this bug to the admin, please!"

	dat += {"
			<b>Power: </b><a href='?src=\ref[src];power=1'>[use_power?"On":"Off"]</a><br>
			<b>Filtering: </b>[current_filter_type]<br><HR>
			<h4>Set Filter Type:</h4>
			<A href='?src=\ref[src];filterset=0'>Phoron</A><BR>
			<A href='?src=\ref[src];filterset=1'>Oxygen</A><BR>
			<A href='?src=\ref[src];filterset=2'>Nitrogen</A><BR>
			<A href='?src=\ref[src];filterset=3'>Carbon Dioxide</A><BR>
			<A href='?src=\ref[src];filterset=4'>Nitrous Oxide</A><BR>
			<A href='?src=\ref[src];filterset=-1'>Nothing</A><BR>
			<HR>
			<B>Set Flow Rate Limit:</B>
			[src.set_flow_rate]L/s | <a href='?src=\ref[src];set_flow_rate=1'>Change</a><BR>
			<B>Flow rate: </B>[round(last_flow_rate, 0.1)]L/s
			"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[entity_ja(dat)]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")

/obj/machinery/atmospherics/components/trinary/filter/Topic(href, href_list) // -- TLE
	if(!..())
		return FALSE

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["filterset"])
		filter_type = text2num(href_list["filterset"])

		filtered_out.Cut() //no need to create new lists unnecessarily
		switch(filter_type)
			if(0) // removing hydrocarbons
				filtered_out += "phoron"
			if(1) // removing O2
				filtered_out += "oxygen"
			if(2) // removing N2
				filtered_out += "nitrogen"
			if(3) // removing CO2
				filtered_out += "carbon_dioxide"
			if(4) // removing N2O
				filtered_out += "sleeping_agent"

	var/datum/gas_mixture/air1 = AIR1

	if(href_list["set_flow_rate"])
		var/new_flow_rate = input(usr,"Enter new flow rate (0-[air1.volume]L/s)", "Flow Rate Control", set_flow_rate) as num
		set_flow_rate = max(0, min(air1.volume, new_flow_rate))

	if(href_list["power"])
		use_power=!use_power

	update_icon()
	updateUsrDialog()

/obj/machinery/atmospherics/components/trinary/filter/m_filter
	icon_state = "mmap"
	initialize_directions = SOUTH|NORTH|EAST

/obj/machinery/atmospherics/components/trinary/filter/m_filter/on
	icon_state = "mmap_on"
	use_power = 1

/obj/machinery/atmospherics/components/trinary/filter/m_filter/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = WEST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|EAST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|NORTH
		if(WEST)
			initialize_directions = WEST|SOUTH|EAST
