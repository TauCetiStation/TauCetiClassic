/*
 * Modifiable value is a float value you can apply modifiers to.
 *
 * Use cases: Movespeed, actionspeed, beauty.
 *
 * General formula for value is: (val * base_multi + base_additive) * multi + additive
 */
/stat
	parent_type = /datum

	var/stored_value

	var/list/parameters
	var/datum/callback/formula
	var/list/modifiers

	var/needs_updating = FALSE

/stat/New(list/default_parameters, datum/callback/formula)
	src.parameters = default_parameters
	src.formula = formula
	update()

/stat/proc/get()
	if(needs_updating)
		needs_updating = FALSE
		update()

	return stored_value

/stat/proc/update()
	var/old_value = stored_value
	stored_value = formula.Invoke(parameters)
	SEND_SIGNAL(src, COMSIG_STAT_UPDATE, old_value)

/stat/proc/add_modifier(category, datum/stat_modifier/modifier)
	if(modifiers && modifiers[category])
		remove_modifier(category)
	if(!modifiers)
		modifiers = list()

	modifiers[category] = modifier
	modifier.apply(src)

	needs_updating = TRUE

/stat/proc/remove_modifier(category)
	var/datum/stat_modifier/modifier = modifiers[category]

	modifiers -= category
	if(modifiers.len == 0)
		modifiers = null

	modifier.revert(src)
	qdel(modifier)

	needs_updating = TRUE

/stat/proc/set_parameter(parameter, value)
	parameters[parameter] = value
	needs_updating = TRUE

/stat/proc/adjust_parameter(parameter, value)
	parameters[parameter] += value
	needs_updating = TRUE


/datum/stat_modifier

/datum/stat_modifier/proc/apply(stat/stat)

/datum/stat_modifier/proc/revert(stat/stat)
