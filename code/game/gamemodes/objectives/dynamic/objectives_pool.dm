/*
 * A system designed to provide pseudo-random objectives so that antagonists go to conflicts with station
*/
/datum/objectives_pool
	var/list/main_objectives_pool = list()

/datum/objectives_pool/proc/generate_objectives_pool(list/datums_to_process)
	for(var/some_datum in datums_to_process)
		// /datum/faction and /datum/role have same syntax
		var/datum/faction/faction_or_role = some_datum
		if(faction_or_role.objectives_ruleset_type)
			var/datum/objective_ruleset/OR = new faction_or_role.objectives_ruleset_type(src)
			main_objectives_pool[faction_or_role.type] += OR.get_objectives()
			qdel(OR)

/datum/objectives_pool/proc/give_all_objectives(list/datums_to_process)
	for(var/datum/D in datums_to_process)
		give_objectives_to(D)

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

	//var/list/set_of_objectives = pick_n_take(main_objectives_pool[faction_or_role.type])
	var/list/set_of_objectives = pick(main_objectives_pool[faction_or_role.type])
	for(var/datum/objective/objective as anything in set_of_objectives)
		objective_holder.AddObjective(objective, mind, mind ? null : faction_or_role)
