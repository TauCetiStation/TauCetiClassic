/datum/objective_ruleset
	var/objectives_amount

	var/datum/objectives_pool/master_pool

/datum/objective_ruleset/New(datum/objectives_pool/_master_pool)
	master_pool = _master_pool

/datum/objective_ruleset/proc/get_main_objectives()
	return

/datum/objective_ruleset/proc/get_objectives()
	return

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

/datum/objective_ruleset/standart/get_main_objectives()
	var/list/all_objectives = get_all_values_from_list(master_pool.main_objectives_pool)
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
	return list(get_main_objectives() + survive_objective)

/datum/objective_ruleset/standart/one
	objectives_amount = 1

/datum/objective_ruleset/standart/two
	objectives_amount = 2

/datum/objective_ruleset/standart/three
	objectives_amount = 3

/datum/objective_ruleset/standart/four
	objectives_amount = 4
