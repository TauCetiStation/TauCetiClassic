/datum/space_level
	var/name = "NAME MISSING"
	var/list/traits
	var/z_value = 1 //actual z placement
	var/linkage = UNAFFECTED
	var/envtype = ENV_TYPE_SPACE

	// environment-based variables
	var/post_gen_type
	var/turf/base_turf_type
	var/datum/gas_mixture/base_air
	var/external_sensor_pressure
	var/image/turf_image

/datum/space_level/New(new_z, new_name, list/new_traits = list())
	z_value = new_z
	name = new_name
	traits = new_traits
	linkage = new_traits[ZTRAIT_LINKAGE]
	envtype = new_traits[ZTRAIT_ENV_TYPE]

	update_envtype()

/datum/space_level/proc/update_envtype()
	switch(envtype)
		if (ENV_TYPE_SPACE)
			base_turf_type = /turf/space
		if (ENV_TYPE_SNOW)
			base_turf_type = /turf/simulated/snow
			post_gen_type = /datum/map_generator/snow
		else
			error("[envtype] is not valid environment type, revert to space")
			envtype = ENV_TYPE_SPACE
			base_turf_type = /turf/space

	//Properties for environment tiles
	var/oxygen = initial(base_turf_type.oxygen)
	var/carbon_dioxide = initial(base_turf_type.carbon_dioxide)
	var/nitrogen = initial(base_turf_type.nitrogen)
	var/phoron = initial(base_turf_type.phoron)

	base_air = new(_temperature=initial(base_turf_type.temperature))
	base_air.adjust_multi("oxygen", oxygen, "carbon_dioxide", carbon_dioxide, "nitrogen", nitrogen, "phoron", phoron)

	external_sensor_pressure = base_air.return_pressure()

	turf_image = image(
		initial(base_turf_type.icon),
		initial(base_turf_type.icon_state),
		layer=initial(base_turf_type.layer)
	)
	turf_image.plane = initial(base_turf_type.plane)

