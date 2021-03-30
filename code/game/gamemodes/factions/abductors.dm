
/datum/faction/abductors
	name = ABDUCTORS
	ID = ABDUCTORS
	logo_state = "abductor-logo"
	required_pref = ABDUCTOR_AGENT

	initroletype = /datum/role/abductor/agent
	initial_role = ABDUCTOR

	logo_state = "abductor-logo"

	max_roles = 2

	var/team_number
	var/list/datum/role/abducted/abductees = list()
	var/static/team_count = 1
	var/static/finished = FALSE

/datum/faction/abductors/New()
	..()
	team_number = team_count++
	name = "Mothership [pick(greek_pronunciation)]"

/datum/faction/abductors/get_initrole_type()
	if(members.len == 0)
		return /datum/role/abductor/agent
	return /datum/role/abductor/scientist

/datum/faction/abductors/forgeObjectives()
	AppendObjective(/datum/objective/experiment)

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

	return dat

/datum/faction/abductors/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in abductor_machinery_list)
		if(c.team == team_number)
			console = c
			break
	return console
