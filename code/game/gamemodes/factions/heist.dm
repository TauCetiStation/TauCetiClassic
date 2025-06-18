/datum/faction/heist
	name = F_HEIST
	ID = F_HEIST
	required_pref = ROLE_RAIDER

	initroletype = /datum/role/vox_raider

	max_roles = 6

	logo_state = "raider-logo"

/datum/faction/heist/can_setup(num_players)
	if(!..())
		return FALSE
	if(length(landmarks_list["Heist"]))
		return TRUE
	return FALSE

/datum/faction/heist/forgeObjectives()
	if(!..())
		return FALSE
	AppendVoxObjectives()
	AppendVoxInviolateObjectives()
	return TRUE

/datum/faction/heist/proc/AppendVoxObjectives()
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

/datum/faction/heist/proc/AppendVoxInviolateObjectives()
	//-All- vox raids have these two (one) objectives. Failing them loses the game.
	AppendObjective(/datum/objective/heist/inviolate_crew)
	AppendObjective(/datum/objective/heist/inviolate_death)

/datum/faction/heist/OnPostSetup()
	. = ..()
	create_spawners(/datum/spawner/vox, max_roles)

/datum/faction/heist/GetScoreboard()
	var/list/objectives = objective_holder.GetObjectives()
	var/success = objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in objectives)
		if(O.completed == OBJECTIVE_LOSS)
			success--

	if(success != objectives.len && success > objectives.len / 2)
		minor_victory = TRUE

	var/dat = ..()
	if(!is_raider_crew_alive())
		dat += "<b>The Vox Raiders have been wiped out!</b>"

	else if(!is_raider_crew_safe())
		dat += "<b>The Vox Raiders have left someone behind!</b>"

	return dat

/datum/faction/heist/proc/is_raider_crew_safe()
	for(var/datum/role/vox_raider/V in members)
		if(!V.antag.current)
			return FALSE
		var/list/area/arkship_areas = list(/area/shuttle/vox/arkship, /area/shuttle/vox/arkship_hold)
		if(!is_type_in_list(get_area(V.antag.current), arkship_areas))
			return FALSE

	return TRUE

/datum/faction/heist/proc/is_raider_crew_alive()
	for(var/datum/role/vox_raider/V in members)
		if(ishuman(V.antag.current) && V.antag.current.stat != DEAD)
			return TRUE

	return FALSE

/datum/faction/heist/saboteurs/can_setup()
	if(!is_type_in_list(/obj/machinery/nuclearbomb, poi_list))
		return FALSE
	if(!length(landmarks_list["Heist"]))
		return FALSE
	return ..()

/datum/faction/heist/saboteurs/AppendVoxObjectives()
	AppendObjective(/datum/objective/heist/stealnuke)

/datum/faction/heist/saboteurs/AppendVoxInviolateObjectives()
	AppendObjective(/datum/objective/heist/inviolate_crew)
