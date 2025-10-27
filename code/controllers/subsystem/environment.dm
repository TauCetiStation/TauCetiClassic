SUBSYSTEM_DEF(environment)
	name = "Environment"

	init_order = SS_INIT_ENVIRONMENT

	flags = SS_NO_FIRE

	var/list/envtype = list()

	var/list/turf_type = list()
	var/list/turf_image = list()

	var/list/air = list()
	var/list/air_pressure = list()

	// Environment datums by environment types (names)
	var/list/env_datums = list()
	// z_levels without initialized environment
	var/list/to_initialize = list()

/datum/controller/subsystem/environment/PreInit()
	for(var/type in subtypesof(/datum/environment))
		var/datum/environment/E = new type
		env_datums[E.name] = E

/datum/controller/subsystem/environment/proc/initialize_zlevels()
	for(var/z_value in to_initialize)
		var/datum/environment/E = env_datums[envtype[z_value]]
		E.initialize_zlevel(z_value)

	to_initialize.Cut()

/datum/controller/subsystem/environment/Initialize(timeofday)
	initialize_zlevels()
	..()

/datum/controller/subsystem/environment/proc/update(z_value, new_envtype)
	if(envtype.len < z_value)
		envtype.len = turf_type.len = turf_image.len = air.len = air_pressure.len = z_value

	if(!env_datums[new_envtype])
		error("[new_envtype] is not valid environment type, revert to space")
		new_envtype = ENV_TYPE_SPACE

	if(envtype[z_value] == new_envtype) // same envtype and initialized
		return

	var/datum/environment/E = env_datums[new_envtype]
	envtype[z_value] = new_envtype
	turf_type[z_value] = E.turf_type
	turf_image[z_value] = E.turf_image
	air[z_value] = E.air
	air_pressure[z_value] = E.air_pressure

	to_initialize |= z_value

/datum/controller/subsystem/environment/StopLoadingMap()
	if(!initialized)
		return

	initialize_zlevels()

