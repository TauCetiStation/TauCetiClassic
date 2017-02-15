var/global/list/datum/pipe_network/pipe_networks = list()

/datum/pipe_network
	var/list/datum/gas_mixture/gases = list() //All of the gas_mixtures continuously connected in this network

	var/list/obj/machinery/atmospherics/normal_members = list()
	var/list/datum/pipeline/line_members = list()
		//membership roster to go through for updates and what not

	var/update = 1
	var/datum/gas_mixture/air_transient = null

/datum/pipe_network/New()
	air_transient = new()

	..()

/datum/pipe_network/Destroy()
	if(gases)
		gases.Cut()

	if(normal_members)
		for(var/obj/machinery/atmospherics/nm in normal_members)
			nm.remove_network(src)
			normal_members -= nm
		normal_members.Cut()

	if(line_members)
		for(var/datum/pipeline/lm in line_members)
			if(lm.network && lm.network == src)
				lm.network = null
			line_members -= lm
		line_members.Cut()

	if(air_transient)
		qdel(air_transient)
		air_transient = null

	pipe_networks.Remove(src)

	return ..()

/datum/pipe_network/process()
	//Equalize gases amongst pipe if called for
	if(update)
		update = 0
		reconcile_air() //equalize_gases(gases)

	//Give pipelines their process call for pressure checking and what not. Have to remove pressure checks for the time being as pipes dont radiate heat - Mport
	//for(var/datum/pipeline/line_member in line_members)
	//	line_member.process()

/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	//Purpose: Generate membership roster
	//Notes: Assuming that members will add themselves to appropriate roster in network_expand()

	if(!start_normal)
		qdel(src)

	start_normal.network_expand(src, reference)

	update_network_gases()

	if((normal_members.len>0)||(line_members.len>0))
		if(!pipe_networks.Find(src))
			pipe_networks += src
	else
		qdel(src)

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver==src) return 0

	normal_members |= giver.normal_members

	line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member in giver.line_members)
		line_member.network = src

	update_network_gases()
	qdel(giver)
	return 1

/datum/pipe_network/proc/update_network_gases()
	//Go through membership roster and make sure gases is up to date

	gases = list()

	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		var/result = normal_member.return_network_air(src)
		if(result) gases += result

	for(var/datum/pipeline/line_member in line_members)
		gases += line_member.air

/datum/pipe_network/proc/reconcile_air()
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	air_transient.volume = 0

	air_transient.oxygen = 0
	air_transient.nitrogen = 0
	air_transient.phoron = 0
	air_transient.carbon_dioxide = 0

	air_transient.trace_gases = list()

	for(var/datum/gas_mixture/gas in gases)
		air_transient.volume += gas.volume
		var/temp_heatcap = gas.heat_capacity()
		total_thermal_energy += gas.temperature*temp_heatcap
		total_heat_capacity += temp_heatcap

		air_transient.oxygen += gas.oxygen
		air_transient.nitrogen += gas.nitrogen
		air_transient.phoron += gas.phoron
		air_transient.carbon_dioxide += gas.carbon_dioxide

		if(gas.trace_gases.len)
			for(var/datum/gas/trace_gas in gas.trace_gases)
				var/datum/gas/corresponding = locate(trace_gas.type) in air_transient.trace_gases
				if(!corresponding)
					corresponding = new trace_gas.type()
					air_transient.trace_gases += corresponding

				corresponding.moles += trace_gas.moles

	if(air_transient.volume > 0)

		if(total_heat_capacity > 0)
			air_transient.temperature = total_thermal_energy/total_heat_capacity

			//Allow air mixture to react
			if(air_transient.react())
				update = 1

		else
			air_transient.temperature = 0

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas in gases)
			gas.oxygen = air_transient.oxygen*gas.volume/air_transient.volume
			gas.nitrogen = air_transient.nitrogen*gas.volume/air_transient.volume
			gas.phoron = air_transient.phoron*gas.volume/air_transient.volume
			gas.carbon_dioxide = air_transient.carbon_dioxide*gas.volume/air_transient.volume

			gas.temperature = air_transient.temperature

			if(air_transient.trace_gases.len)
				for(var/datum/gas/trace_gas in air_transient.trace_gases)
					var/datum/gas/corresponding = locate(trace_gas.type) in gas.trace_gases
					if(!corresponding)
						corresponding = new trace_gas.type()
						gas.trace_gases += corresponding

					corresponding.moles = trace_gas.moles*gas.volume/air_transient.volume
			gas.update_values()
	air_transient.update_values()
	return 1
