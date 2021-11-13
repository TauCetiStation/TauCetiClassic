/datum/objectives_set
	var/datum/faction_or_role // faction or role
	var/list/my_objectives

/datum/objectives_set/New(list/_my_objectives, datum/_faction_or_role)
	my_objectives = _my_objectives
	faction_or_role = _faction_or_role

/*
 * A system designed to provide pseudo-random objectives so that antagonists go to conflicts with station
*/
/datum/objectives_pool
	// antag = instanse of /datum/objectives_set
	var/list/main_objectives_pool = list()

/datum/objectives_pool/proc/get_all_objectives()
	var/list/all_objectives = list()
	for(var/antag in main_objectives_pool)
		all_objectives += main_objectives_pool[antag]
	return all_objectives

/datum/objectives_pool/proc/generate_objectives_for(datum/some_datum)
	// /datum/faction and /datum/role have same syntax
	var/datum/faction/faction_or_role = some_datum
	if(!faction_or_role.objectives_ruleset_type)
		return

	var/datum/objective_ruleset/OR = new faction_or_role.objectives_ruleset_type (src, faction_or_role)
	var/datum/objectives_set/o_set = OR.get_objectives_set()
	qdel(OR)

	main_objectives_pool[faction_or_role] = o_set

// TODO: Remove the dependence of the faction/role on their objective_holder
/datum/objectives_pool/proc/give_objectives_for(datum/faction_or_role)
	if(!main_objectives_pool[faction_or_role])
		return

	// standardized fields
	var/datum/objective_holder/objective_holder

	if(istype(faction_or_role, /datum/faction))
		var/datum/faction/F = faction_or_role
		objective_holder = F.objective_holder

	else if(istype(faction_or_role, /datum/role))
		var/datum/role/R = faction_or_role
		objective_holder = R.objectives // rename this to objective_holder

	var/datum/objectives_set/o_set = main_objectives_pool[faction_or_role]
	for(var/datum/objective/objective as anything in o_set.my_objectives)
		objective_holder.AddObjective(objective) // owners must setted in objective_ruleset
