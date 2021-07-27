/datum/faction/heist
	name = F_HEIST
	ID = F_HEIST
	required_pref = ROLE_RAIDER

	initroletype = /datum/role/vox_raider

	min_roles = 4
	max_roles = 6

	logo_state = "raider-logo"

/datum/faction/heist/can_setup(num_players)
	if(!..())
		return FALSE
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			return TRUE
	return FALSE

/datum/faction/heist/forgeObjectives()
	if(!..())
		return FALSE
	var/max_objectives = pick(2,2,2,2,3,3,3,4)
	var/list/goals = list("kidnap","loot","salvage")

	for(var/i in 1 to max_objectives)
		var/goal = pick(goals)

		if(goal == "kidnap")
			goals -= "kidnap"
			AppendObjective(/datum/objective/target/kidnap)
		else if(goal == "loot")
			AppendObjective(/datum/objective/heist/loot)
		else
			AppendObjective(/datum/objective/heist/salvage)

	//-All- vox raids have these two (one) objectives. Failing them loses the game.
	AppendObjective(/datum/objective/heist/inviolate_crew)
	AppendObjective(/datum/objective/heist/inviolate_death)
	return TRUE

/datum/faction/heist/OnPostSetup()
	//Build a list of spawn points.
	var/list/turf/raider_spawn = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			raider_spawn += get_turf(L)
			qdel(L)
			continue

	var/index = 1
	for(var/datum/role/R in members)
		if(index > raider_spawn.len)
			index = 1

		R.antag.current.forceMove(raider_spawn[index])
		index++
	return ..()

/datum/faction/heist/GetScoreboard()
	var/list/objectives = objective_holder.GetObjectives()
	var/success = objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in objectives)
		if(!(O.check_completion()))
			success--

	if(success != objectives.len && success > objectives.len / 2)
		minor_victory = TRUE

	var/dat = ..()
	if(!is_raider_crew_alive())
		dat += "<b>The Vox Raiders have been wiped out!</b>"

	else if(!is_raider_crew_safe())
		dat += "<b>The Vox Raiders have left someone behind!</b>"

	return dat

/datum/faction/heist/check_win()
	if(vox_shuttle_location && (vox_shuttle_location == "start"))
		return TRUE

	return FALSE

/datum/faction/heist/proc/is_raider_crew_safe()
	for(var/datum/role/vox_raider/V in members)
		if(!V.antag.current)
			return FALSE
		if(get_area(V.antag.current) != get_area_by_type(/area/shuttle/vox/arkship))
			return FALSE

	return TRUE

/datum/faction/heist/proc/is_raider_crew_alive()
	for(var/datum/role/vox_raider/V in members)
		if(ishuman(V.antag.current) && V.antag.current.stat == DEAD)
			return TRUE

	return FALSE
