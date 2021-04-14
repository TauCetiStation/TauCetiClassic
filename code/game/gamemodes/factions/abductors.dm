
/datum/faction/abductors
	name = ABDUCTORS
	ID = ABDUCTORS
	logo_state = "abductor-logo"
	required_pref = ROLE_ABDUCTOR

	initroletype = /datum/role/abductor/agent

	logo_state = "abductor-logo"

	min_roles = 2
	max_roles = 2

	var/team_number
	var/list/datum/role/abducted/abductees = list()
	var/static/team_count = 1
	var/static/finished = FALSE

/datum/faction/abductors/get_initrole_type()
	if(members.len == 0)
		return /datum/role/abductor/agent
	return /datum/role/abductor/scientist

/datum/faction/abductors/OnPostSetup()
	for(var/datum/role/R in members)
		if(istype(R, /datum/role/abductor/scientist))
			var/obj/effect/landmark/L = scientist_landmarks[team_number]
			R.antag.current.forceMove(L.loc)

		else if(istype(R, /datum/role/abductor/agent/))
			var/obj/effect/landmark/L = agent_landmarks[team_number]
			R.antag.current.forceMove(L.loc)

	return ..()

/datum/faction/abductors/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/experiment)
	return TRUE

/datum/faction/abductors/can_setup()
	if(!..())
		return FALSE
	team_number = team_count++
	name = "Mothership [pick(greek_pronunciation)]"
	return TRUE

/datum/faction/abductors/check_win()
	if(finished)
		return FALSE

	for(var/datum/objective/experiment/E in objective_holder.GetObjectives())
		if(E.check_completion())
			SSshuttle.incall(0.5)
			SSshuttle.announce_emer_called.play()
			finished = TRUE
			return TRUE

	return FALSE

/datum/faction/abductors/GetScoreboard()
	var/dat = ..()

	if(abductees.len)
		dat += "<br><b>The abductees:</b>"
		for(var/datum/role/abducted/A in abductees)
			dat += A.GetScoreboard()
			dat += "<br>"

	return dat

/datum/faction/abductors/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in abductor_machinery_list)
		if(c.team == team_number)
			console = c
			break
	return console
