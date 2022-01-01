/datum/space_level
	var/name = "NAME MISSING"
	var/list/traits
	var/z_value = 1 //actual z placement
	var/linkage = CROSSLINKED

	// environment variables
	var/envtype = ENV_TYPE_SPACE
	var/turf/base_turf_type
	var/datum/gas_mixture/base_air

/datum/space_level/New(new_z, new_name, list/new_traits = list())
	z_value = new_z
	name = new_name
	traits = new_traits
	linkage = new_traits[ZTRAIT_LINKAGE]
	envtype = new_traits[ZTRAIT_ENV_TYPE] || envtype

	update_envtype()

/datum/space_level/proc/update_envtype()
	switch(envtype)
		if (ENV_TYPE_SPACE)
			base_turf_type = /turf/space
		if (ENV_TYPE_SNOW)
			base_turf_type = /turf/simulated/snow
		else
			error("[envtype] is not valid environment type")

	//Properties for open tiles (/floor)
	var/oxygen = initial(base_turf_type.oxygen)
	var/carbon_dioxide = initial(base_turf_type.carbon_dioxide)
	var/nitrogen = initial(base_turf_type.nitrogen)
	var/phoron = initial(base_turf_type.phoron)

	base_air = new(_temperature=initial(base_turf_type.temperature))
	base_air.adjust_multi("oxygen", oxygen, "carbon_dioxide", carbon_dioxide, "nitrogen", nitrogen, "phoron", phoron)

