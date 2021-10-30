/datum/objectives_set
	var/list/my_objectives
	var/used = FALSE

/datum/objectives_set/New(list/_my_objectives)
	my_objectives = _my_objectives

/*
 * A system designed to provide pseudo-random objectives so that antagonists go to conflicts with station
*/
/datum/objectives_pool
	// type = list(instanse of /datum/objectives_set, instanse of /datum/objectives_set)
	var/list/main_objectives_pool = list()

/datum/objectives_pool/proc/get_all_objectives()
	var/list/all_objectives = list()
	for(var/type in main_objectives_pool)
		var/list/sets = main_objectives_pool[type]
		for(var/datum/objectives_set/o_set as anything in sets)
			all_objectives += o_set.my_objectives
	return all_objectives

/datum/objectives_pool/proc/generate_objectives_for(datum/some_datum)
	// /datum/faction and /datum/role have same syntax
	var/datum/faction/faction_or_role = some_datum
	if(!faction_or_role.objectives_ruleset_type)
		return
	var/datum/objective_ruleset/OR = new faction_or_role.objectives_ruleset_type(src, faction_or_role)
	var/datum/objectives_set/o_set = OR.get_objectives_set()
	qdel(OR)

	if(!main_objectives_pool[faction_or_role.type])
		main_objectives_pool[faction_or_role.type] = list()

	main_objectives_pool[faction_or_role.type] += o_set

// TODO: Remove the dependence of the faction/role on their objective_holder
/datum/objectives_pool/proc/give_objectives_for(datum/faction_or_role)
	if(!main_objectives_pool[faction_or_role.type])
		return

	// standardized fields
	var/datum/objective_holder/objective_holder
	var/mind = null

	if(istype(faction_or_role, /datum/faction))
		var/datum/faction/F = faction_or_role
		objective_holder = F.objective_holder

	else if(istype(faction_or_role, /datum/role))
		var/datum/role/R = faction_or_role
		objective_holder = R.objectives
		mind = R.antag

	var/list/datum/objectives_set/available_sets = list()
	for(var/datum/objectives_set/o_set as anything in main_objectives_pool[faction_or_role.type])
		if(!o_set.used)
			available_sets += o_set
	var/datum/objectives_set/o_set = pick(available_sets)
	o_set.used = TRUE
	for(var/datum/objective/objective as anything in o_set.my_objectives)
		objective_holder.AddObjective(objective, mind, mind ? null : faction_or_role)
