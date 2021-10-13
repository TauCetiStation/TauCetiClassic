/datum/objective_ruleset
	var/objectives_amount

	var/datum/objectives_pool/master_pool

/datum/objective_ruleset/New(datum/objectives_pool/_master_pool)
	master_pool = _master_pool

/datum/objective_ruleset/proc/get_pseudorandom_objectives()
	return

/datum/objective_ruleset/proc/get_all_objectives()
	return get_all_values_from_assoc_list(master_pool.main_objectives_pool)

/datum/objective_ruleset/proc/get_objectives()
	return

/*
 * Standart
 */
/datum/objective_ruleset/standart
	objectives_amount = 3

	// The probability that the goal of the objective will NOT be chosen by chance
	var/pseudorandom_chance = 50

	// type = weight
	var/list/main_objectives = list(
		/datum/objective/target/assassinate = 80,
		/datum/objective/target/harm = 60,
		/datum/objective/steal = 60,
		/datum/objective/target/protect = 40,
		/datum/objective/target/debrain = 40,
		/datum/objective/target/dehead = 40,
	)

	// type = weight
	var/list/survive_objectives = list(
		/datum/objective/escape = 80,
		/datum/objective/survive = 60,
		/datum/objective/hijack = 1,
	)

/datum/objective_ruleset/standart/get_pseudorandom_objectives()
	var/list/all_objectives = get_all_objectives()
	var/list/new_objectives = list()

	for(var/i = 1 to objectives_amount)
		var/obj_type = pickweight(main_objectives)
		var/datum/objective/new_obj = new obj_type

		// really random target is not provided here, because ruleset is optional setting
		if(prob(pseudorandom_chance))
			new_obj.auto_target = !new_obj.find_pseudorandom_target(all_objectives)

		new_objectives += new_obj

	return new_objectives

/datum/objective_ruleset/standart/get_objectives()
	var/objective_type = pickweight(survive_objectives)
	var/datum/objective/survive_objective = new objective_type
	return list(get_pseudorandom_objectives() + survive_objective)

/datum/objective_ruleset/standart/one
	objectives_amount = 1

/datum/objective_ruleset/standart/two
	objectives_amount = 2

/datum/objective_ruleset/standart/three
	objectives_amount = 3

/datum/objective_ruleset/standart/four
	objectives_amount = 4

/*
 * Families
 */
/datum/objective_ruleset/families

/datum/objective_ruleset/families/get_pseudorandom_objectives()
	var/list/all_objectives = get_all_objectives()
	var/list/all_objectives_types = make_associative(get_types_of_objects_list(all_objectives))

	for(var/datum/objective/gang/objective in all_objectives)
		if(!objective.conflicting_types.len)
			continue
		for(var/type in objective.conflicting_types)
			if(!all_objectives_types[type])
				return list(new type)

	var/list/gang_objectives_types = subtypesof(/datum/objective/gang) - /datum/objective/gang/points
	var/picked_type = pick(gang_objectives_types)
	return list(new picked_type)

/datum/objective_ruleset/families/get_objectives()
	var/datum/objective/points = new /datum/objective/gang/points
	return list(get_pseudorandom_objectives() + points)
