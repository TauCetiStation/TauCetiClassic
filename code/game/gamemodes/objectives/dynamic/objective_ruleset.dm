/datum/objective_ruleset
	var/objectives_amount

	var/datum/objectives_pool/master_pool
	var/datum/faction_or_role

/datum/objective_ruleset/New(datum/objectives_pool/_master_pool, datum/_faction_or_role)
	master_pool = _master_pool
	faction_or_role = _faction_or_role

/datum/objective_ruleset/proc/get_objectives()
	return

/datum/objective_ruleset/proc/get_all_objectives()
	return master_pool.get_all_objectives()

/datum/objective_ruleset/proc/get_objectives_set()
	return

/datum/objective_ruleset/proc/create_objective(type)
	var/datum/objective/O = new type
	if(istype(faction_or_role, /datum/faction))
		O.faction = faction_or_role
	else if(istype(faction_or_role, /datum/role))
		var/datum/role/R = faction_or_role
		O.owner = R.antag
	return O

/datum/objective_ruleset/proc/create_objectives_set(objectives)
	var/datum/objectives_set/OS = new(objectives, faction_or_role)
	return OS

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

	// If it was not possible to find the target for a pseudorandom objective for the first time,
	// then such a objective can no longer be pseudorandom
	var/list/blocked_pseudorandom = list()

/datum/objective_ruleset/standart/New()
	..()
	if(!istype(faction_or_role, /datum/role))
		return
	var/datum/role/R = faction_or_role
	if(issilicon(R.antag.current))
		main_objectives = list(
			/datum/objective/target/assassinate = 10,
		)

		survive_objectives = list(
			/datum/objective/survive = 90,
			/datum/objective/block = 10,
		)

/datum/objective_ruleset/standart/get_objectives()
	var/list/all_objectives = get_all_objectives()
	var/list/new_objectives = list()

	var/i = 1
	while(i != objectives_amount)
		var/obj_type = pickweight(main_objectives)
		var/datum/objective/new_obj = create_objective(obj_type)

		if(prob(pseudorandom_chance) && !blocked_pseudorandom[obj_type] && new_obj.conflicting_types.len)
			new_obj.auto_target = !new_obj.find_pseudorandom_target(all_objectives, new_objectives)
			if(new_obj.auto_target)
				blocked_pseudorandom[obj_type] = TRUE
				qdel(new_obj)
				continue

		new_objectives += new_obj
		i++

	return new_objectives

/datum/objective_ruleset/standart/get_objectives_set()
	var/objective_type = pickweight(survive_objectives)
	var/datum/objective/survive_objective = create_objective(objective_type)
	return create_objectives_set(get_objectives() + survive_objective)

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

/datum/objective_ruleset/families/get_objectives()
	var/list/all_objectives = get_all_objectives()
	var/list/all_objectives_types = make_associative(get_types_of_objects_list(all_objectives))

	for(var/datum/objective/gang/objective in all_objectives)
		if(!objective.conflicting_types.len)
			continue
		for(var/type in objective.conflicting_types)
			if(!all_objectives_types[type])
				return list(create_objective(type))

	var/list/gang_objectives_types = subtypesof(/datum/objective/gang) + /datum/objective/target/assassinate/kill_head - /datum/objective/gang/points
	var/picked_type = pick(gang_objectives_types)
	return list(create_objective(picked_type))

/datum/objective_ruleset/families/get_objectives_set()
	var/datum/objective/points = create_objective(/datum/objective/gang/points)
	return create_objectives_set(get_objectives() + points)
