/datum/environment
	var/name

	// Basic turf type for environment
	var/turf/environment/turf_type
	// Environment generator type
	var/datum/map_generator/gen_type
	// Area to replace /area/space (null means /area/space)
	var/area/area_type
	// Whether to process environment in SSweather
	var/has_weather = FALSE

	// Computed environment information
	var/image/turf_image
	var/datum/gas_mixture/air
	var/air_pressure

/datum/environment/New()
	. = ..()
	compute_additional_info()

/datum/environment/proc/compute_additional_info()
	//Properties for environment tiles
	var/oxygen = initial(turf_type.oxygen)
	var/carbon_dioxide = initial(turf_type.carbon_dioxide)
	var/nitrogen = initial(turf_type.nitrogen)
	var/phoron = initial(turf_type.phoron)

	air = new(_temperature=initial(turf_type.temperature))
	air.adjust_multi(
		"oxygen", oxygen, "carbon_dioxide", carbon_dioxide,
		"nitrogen", nitrogen, "phoron", phoron
		)

	air_pressure = air.return_pressure()

	turf_image = image(
		initial(turf_type.icon),
		initial(turf_type.icon_state),
		layer=initial(turf_type.layer)
	)
	turf_image.plane = initial(turf_type.plane)

/datum/environment/proc/initialize_zlevel(z_value)
	if(has_weather)
		SSweather.make_z_eligible(z_value)
	
	if(area_type)
		var/list/turfs = get_area_turfs(/area/space, FALSE, z_value)
		var/area/new_area = get_area_by_type(area_type) || new area_type
		new_area.contents.Add(turfs)

	if(gen_type)
		var/datum/map_generator/gen = new gen_type
		gen.defineRegion(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value))
		gen.generate()
