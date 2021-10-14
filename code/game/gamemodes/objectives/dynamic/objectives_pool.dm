/datum/objectives_set
	var/list/my_objectives = list()
	var/used = FALSE

/datum/objectives_set/New(list/_my_objectives)
	my_objectives = _my_objectives

/*
 * A system designed to provide pseudo-random objectives so that antagonists go to conflicts with station
*/
/datum/objectives_pool
	// type = list(instanse of /datum/objectives_set, instanse of /datum/objectives_set)
	var/list/main_objectives_pool = list()

/datum/objectives_pool/proc/generate_objectives_pool(list/datums_to_process)
	for(var/some_datum in datums_to_process)
		// /datum/faction and /datum/role have same syntax
		var/datum/faction/faction_or_role = some_datum
		if(!faction_or_role.objectives_ruleset_type)
			continue
		var/datum/objective_ruleset/OR = new faction_or_role.objectives_ruleset_type(src, faction_or_role)
		var/datum/objectives_set/o_set = new(OR.get_objectives())
		main_objectives_pool[faction_or_role.type] += o_set
		qdel(OR)

/datum/objectives_pool/proc/give_objectives_to(datum/faction_or_role)
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
