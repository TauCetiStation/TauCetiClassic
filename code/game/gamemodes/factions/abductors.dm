/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/abductor/console/atom_init_late()
	var/obj/machinery/abductor/console/c = new /obj/machinery/abductor/console(src.loc)
	c.team = team
	c.Initialize()
	qdel(src)

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist

var/global/list/obj/effect/landmark/abductor/agent_landmarks[MAX_ABDUCTOR_TEAMS]
var/global/list/obj/effect/landmark/abductor/scientist_landmarks[MAX_ABDUCTOR_TEAMS]

var/global/abductor_landmarks_setuped = FALSE

/datum/faction/abductors
	name = F_ABDUCTORS
	ID = F_ABDUCTORS
	required_pref = ROLE_ABDUCTOR

	initroletype = /datum/role/abductor/agent

	logo_state = "abductor-logo"

	min_roles = 2
	max_roles = 2

	var/team_number
	var/list/datum/role/abducted/abductees = list()
	var/static/team_count = 1
	var/static/finished = FALSE

/datum/faction/abductors/New()
	..()
	if(!abductor_landmarks_setuped)
		abductor_landmarks_setuped = TRUE
		setup_landmarks()

/datum/faction/abductors/proc/setup_landmarks()
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

/datum/faction/abductors/get_initrole_type()
	if(members.len == 0)
		return /datum/role/abductor/agent
	return /datum/role/abductor/scientist

/datum/faction/abductors/OnPostSetup()
	for(var/datum/role/R in members)
		if(istype(R, /datum/role/abductor/scientist))
			var/obj/effect/landmark/L = scientist_landmarks[team_number]
			R.antag.current.forceMove(L.loc)

		else if(istype(R, /datum/role/abductor/agent))
			var/obj/effect/landmark/L = agent_landmarks[team_number]
			R.antag.current.forceMove(L.loc)

	return ..()

/datum/faction/abductors/forgeObjectives()
	if(!..())
		return FALSE
	var/datum/objective/experiment/E = AppendObjective(/datum/objective/experiment)
	if(E)
		E.team = team_number
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
			return FALSE

	return FALSE

/datum/faction/abductors/GetScoreboard()
	var/dat = ..()

	if(abductees.len)
		dat += "<br><b>The abductees:</b><br>"
		for(var/datum/role/abducted/A in abductees)
			dat += A.GetScoreboard()
			dat += "<br>"

	return dat

/datum/faction/abductors/proc/get_team_console(team)
	for(var/obj/machinery/abductor/console/c in abductor_machinery_list)
		if(c.team == team_number)
			return c
