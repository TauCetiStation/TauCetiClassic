/datum/stat_modifier/increase_parameters
	var/list/parameters

/datum/stat_modifier/increase_parameters/New(list/parameters)
	src.parameters = parameters

/datum/stat_modifier/increase_parameters/apply(stat/stat)
	for(var/parameter in parameters)
		stat.adjust_parameter(parameter, parameters[parameter])

/datum/stat_modifier/increase_parameters/revert(stat/stat)
	for(var/parameter in parameters)
		stat.adjust_parameter(parameter, -parameters[parameter])

/datum/stat_modifier/increase_parameters/proc/update(stat/stat, list/new_parameters)
	revert(stat)
	parameters = new_parameters
	apply(stat)


/stat/proc/set_increase_parameters(category, list/parameters)
	var/datum/stat_modifier/increase_parameters/IP = new(parameters)
	add_modifier(category, IP)
