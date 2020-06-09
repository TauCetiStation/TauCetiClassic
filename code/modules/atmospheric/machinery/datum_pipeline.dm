/datum/pipeline
	var/datum/gas_mixture/air
	var/list/datum/gas_mixture/other_airs

	var/list/obj/machinery/atmospherics/pipe/members
	var/list/obj/machinery/atmospherics/components/other_atmosmch

	var/update = TRUE
	var/alert_pressure = 0

/datum/pipeline/New()
	other_airs = list()
	members = list()
	other_atmosmch = list()
	SSair.networks += src

/datum/pipeline/Destroy()
	SSair.networks -= src

	if(air && air.volume)
		temporarily_store_air()

	for(var/obj/machinery/atmospherics/pipe/P in members)
		P.parent = null

	for(var/obj/machinery/atmospherics/components/C in other_atmosmch)
		C.nullifyPipenet(src)

	return ..()

/datum/pipeline/process()
	if(update)
		update = FALSE
		reconcile_air()
	//update = air.react()

	//Check to see if pressure is within acceptable limits
	var/pressure = air.return_pressure()
	if(pressure > alert_pressure)
		var/obj/machinery/atmospherics/pipe/member = pick(members) // pick random member, because why not.
		if(member)
			member.check_pressure(pressure)

/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/base)
	var/volume = 0

	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/E = base
		alert_pressure = E.alert_pressure
		volume = E.volume
		members += E
		if(E.air_temporary)
			air = E.air_temporary
			E.air_temporary = null
	else
		addMachineryMember(base)

	if(!air)
		air = new

	var/list/possible_expansions = list(base)
	while(possible_expansions.len > 0)
		for(var/obj/machinery/atmospherics/borderline in possible_expansions)

			var/list/result = borderline.pipeline_expansion(src)

			if(result.len > 0)
				for(var/obj/machinery/atmospherics/P in result)
					if(istype(P, /obj/machinery/atmospherics/pipe))
						var/obj/machinery/atmospherics/pipe/item = P
						if(!members.Find(item))

							if(item.parent)
								var/static/pipenetwarnings = 10
								if(pipenetwarnings > 0)
									warning("build_pipeline(): [item.type] added to a pipenet while still having one. (pipes leading to the same spot stacking in one turf) Nearby: ([item.x], [item.y], [item.z])")
									pipenetwarnings -= 1
									if(pipenetwarnings == 0)
										warning("build_pipeline(): further messages about pipenets will be supressed")
							members += item
							possible_expansions += item

							alert_pressure = min(alert_pressure, item.alert_pressure)

							volume += item.volume
							item.parent = src

							if(item.air_temporary)
								air.merge(item.air_temporary)
								item.air_temporary = null
					else
						P.setPipenet(src, borderline)
						addMachineryMember(P)

			possible_expansions -= borderline

	air.volume = volume

/datum/pipeline/proc/addMachineryMember(obj/machinery/atmospherics/components/C)
	other_atmosmch |= C
	var/datum/gas_mixture/G = C.returnPipenetAir(src)
	if(!G)
		stack_trace("addMachineryMember: Null gasmix added to pipeline datum from [C] which is of type [C.type]. Nearby: ([C.x], [C.y], [C.z])")
	other_airs |= G

/datum/pipeline/proc/addMember(obj/machinery/atmospherics/A, obj/machinery/atmospherics/N)
	if(istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = A
		P.parent = src
		var/list/adjacent = P.pipeline_expansion()
		for(var/obj/machinery/atmospherics/pipe/I in adjacent)
			if(I.parent == src)
				continue
			var/datum/pipeline/E = I.parent
			merge(E)
		if(!members.Find(P))
			members += P
			air.volume += P.volume
	else
		A.setPipenet(src, N)
		addMachineryMember(A)

/datum/pipeline/proc/merge(datum/pipeline/E)
	air.volume += E.air.volume
	members.Add(E.members)
	for(var/obj/machinery/atmospherics/pipe/S in E.members)
		S.parent = src
	air.merge(E.air)
	for(var/obj/machinery/atmospherics/components/C in E.other_atmosmch)
		C.replacePipenet(E, src)
	other_atmosmch.Add(E.other_atmosmch)
	other_airs.Add(E.other_airs)
	E.members.Cut()
	E.other_atmosmch.Cut()
	qdel(E)

/obj/machinery/atmospherics/proc/addMember(obj/machinery/atmospherics/A)
	return

/obj/machinery/atmospherics/pipe/addMember(obj/machinery/atmospherics/A)
	parent.addMember(A, src)

/obj/machinery/atmospherics/components/addMember(obj/machinery/atmospherics/A)
	var/datum/pipeline/P = returnPipenet(A)
	P.addMember(A, src)


/datum/pipeline/proc/temporarily_store_air()
	//Update individual gas_mixtures by volume ratio

	for(var/obj/machinery/atmospherics/pipe/member in members)
		member.air_temporary = new
		member.air_temporary.copy_from(air)
		member.air_temporary.volume = member.volume

		member.air_temporary.multiply(member.volume / air.volume)

		member.air_temporary.temperature = air.temperature

/datum/pipeline/proc/mingle_with_turf(turf/simulated/target, mingle_volume)
	var/datum/gas_mixture/air_sample = air.remove_ratio(mingle_volume / air.volume)
	air_sample.volume = mingle_volume

	if(istype(target) && target.zone)
		//Have to consider preservation of group statuses
		var/datum/gas_mixture/turf_copy = new

		turf_copy.copy_from(target.zone.air)
		turf_copy.volume = target.zone.air.volume //Copy a good representation of the turf from parent group

		equalize_gases(list(air_sample, turf_copy))
		air.merge(air_sample)

		turf_copy.subtract(target.zone.air)

		target.zone.air.merge(turf_copy)

	else
		var/datum/gas_mixture/turf_air = target.return_air()

		equalize_gases(list(air_sample, turf_air))
		air.merge(air_sample)
		//turf_air already modified by equalize_gases()

	update = TRUE

/datum/pipeline/proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
	var/total_heat_capacity = air.heat_capacity()
	var/partial_heat_capacity = total_heat_capacity * (share_volume / air.volume)

	if(istype(target, /turf/simulated))
		var/turf/simulated/modeled_location = target

		if(modeled_location.blocks_air)

			if((modeled_location.heat_capacity > 0) && (partial_heat_capacity > 0))
				var/delta_temperature = air.temperature - modeled_location.temperature

				var/heat = thermal_conductivity * delta_temperature * \
					(partial_heat_capacity * modeled_location.heat_capacity / (partial_heat_capacity + modeled_location.heat_capacity))

				air.temperature -= heat / total_heat_capacity
				modeled_location.temperature += heat / modeled_location.heat_capacity

		else
			var/delta_temperature = 0
			var/sharer_heat_capacity = 0

			if(modeled_location.zone)
				delta_temperature = (air.temperature - modeled_location.zone.air.temperature)
				sharer_heat_capacity = modeled_location.zone.air.heat_capacity()
			else
				delta_temperature = (air.temperature - modeled_location.air.temperature)
				sharer_heat_capacity = modeled_location.air.heat_capacity()

			var/self_temperature_delta = 0
			var/sharer_temperature_delta = 0

			if((sharer_heat_capacity > 0) && (partial_heat_capacity > 0))
				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity * sharer_heat_capacity / (partial_heat_capacity + sharer_heat_capacity))

				self_temperature_delta = -heat / total_heat_capacity
				sharer_temperature_delta = heat / sharer_heat_capacity
			else
				return TRUE

			air.temperature += self_temperature_delta

			if(modeled_location.zone)
				modeled_location.zone.air.temperature += sharer_temperature_delta / modeled_location.zone.air.group_multiplier
			else
				modeled_location.air.temperature += sharer_temperature_delta


	else
		if((target.heat_capacity > 0) && (partial_heat_capacity > 0))
			var/delta_temperature = air.temperature - target.temperature

			var/heat = thermal_conductivity * delta_temperature * \
				(partial_heat_capacity * target.heat_capacity / (partial_heat_capacity+target.heat_capacity))

			air.temperature -= heat/total_heat_capacity
	update = TRUE

/datum/pipeline/proc/return_air()
	. = other_airs + air
	if(null in .)
		stack_trace("[src] has one or more null gas mixtures, which may cause bugs. Null mixtures will not be considered in reconcile_air().")
		return removeNullsFromList(.)

/datum/pipeline/proc/reconcile_air()
//	equalize_gases(other_airs)

	var/list/datum/gas_mixture/GL = list()
	var/list/datum/pipeline/PL = list()
	PL += src

	for(var/i = 1; i <= PL.len; i++) //can't do a for-each here because we may add to the list within the loop
		var/datum/pipeline/P = PL[i]
		if(!P)
			continue
		GL += P.return_air()
		for(var/obj/machinery/atmospherics/components/binary/valve/V in P.other_atmosmch)
			if(V.open)
				PL |= V.PARENT1
				PL |= V.PARENT2
		for(var/obj/machinery/atmospherics/components/trinary/tvalve/V in P.other_atmosmch)
			if(V.opened_to_side) // side: Parent1 <-> Parent2
				if(P == V.PARENT1 || P == V.PARENT2)
					PL |= V.PARENT1
					PL |= V.PARENT2
			else // straight: Parent1 <-> Parent3
				if(P == V.PARENT1 || P == V.PARENT3)
					PL |= V.PARENT1
					PL |= V.PARENT3
		for(var/obj/machinery/atmospherics/components/unary/portables_connector/C in P.other_atmosmch)
			if(C.connected_device)
				GL += C.portableConnectorReturnAir()

	equalize_gases(GL)

// surface must be the surface area in m^2
/datum/pipeline/proc/radiate_heat_to_space(surface, thermal_conductivity)
	var/gas_density = air.total_moles/air.volume
	thermal_conductivity *= min(gas_density / ( RADIATOR_OPTIMUM_PRESSURE / (R_IDEAL_GAS_EQUATION * GAS_CRITICAL_TEMPERATURE) ), 1) //mult by density ratio

	var/heat_gain = get_thermal_radiation(air.temperature, surface, RADIATOR_EXPOSED_SURFACE_AREA_RATIO, thermal_conductivity)

	air.add_thermal_energy(heat_gain)
	update = TRUE

//Returns the amount of heat gained while in space due to thermal radiation (usually a negative value)
//surface - the surface area in m^2
//exposed_surface_ratio - the proportion of the surface that is exposed to sunlight
//thermal_conductivity - a multipler on the heat transfer rate. See OPEN_HEAT_TRANSFER_COEFFICIENT and friends
/proc/get_thermal_radiation(surface_temperature, surface, exposed_surface_ratio, thermal_conductivity)
	//*** Gain heat from sunlight, then lose heat from radiation.

	// We only get heat from the star on the exposed surface area.
	// If the HE pipes gain more energy from AVERAGE_SOLAR_RADIATION than they can radiate, then they have a net heat increase.
	. = AVERAGE_SOLAR_RADIATION * (exposed_surface_ratio * surface) * thermal_conductivity

	// Previously, the temperature would enter equilibrium at 26C or 294K.
	// Only would happen if both sides (all 2 square meters of surface area) were exposed to sunlight.  We now assume it aligned edge on.
	// It currently should stabilise at 129.6K or -143.6C
	. -= surface * STEFAN_BOLTZMANN_CONSTANT * thermal_conductivity * (surface_temperature - COSMIC_RADIATION_TEMPERATURE) ** 4
