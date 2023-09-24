/mob/living/carbon/human/abductor/event
	spawner_args = list(/datum/spawner/living/abductor, 2 MINUTES)

/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/abductor/console/atom_init_late()
	var/obj/machinery/abductor/console/c = new /obj/machinery/abductor/console(src.loc)
	c.Initialize()
	qdel(src)

/obj/effect/landmark/abductor/agent
	name = "Abductor agent"
/obj/effect/landmark/abductor/scientist
	name = "Abductor scientist"

var/global/list/agent_landmarks[MAX_ABDUCTOR_TEAMS]
var/global/list/scientist_landmarks[MAX_ABDUCTOR_TEAMS]

/datum/faction/abductors
	name = F_ABDUCTORS
	ID = F_ABDUCTORS
	required_pref = ROLE_ABDUCTOR

	initroletype = /datum/role/abductor/scientist
	roletype = /datum/role/abductor/agent

	logo_state = "abductor-logo"

	max_roles = 8

	var/num_agents = 0
	var/num_scientists = 0
	var/static/finished = FALSE
	var/abductor_landmarks_setuped = FALSE

/datum/faction/abductors/New()
	..()
	if(!abductor_landmarks_setuped)
		abductor_landmarks_setuped = TRUE
		setup_landmarks()
	//Always max teams, because major event
	create_spawners(/datum/spawner/abductor, max_roles)

/datum/faction/abductors/proc/setup_landmarks()
	for(var/obj/effect/landmark/abductor/A as anything in landmarks_list["Abductor agent"])
		agent_landmarks[A.team] = A
	for(var/obj/effect/landmark/abductor/A as anything in landmarks_list["Abductor scientist"])
		scientist_landmarks[A.team] = A

/datum/faction/abductors/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/experiment/long)
	return TRUE

/datum/faction/abductors/HandleNewMind(datum/mind/M, laterole)
	var/datum/role/newRole = ..()
	if(!newRole)
		return
	num_scientists++
	newRole.OnPostSetup()

/datum/faction/abductors/HandleRecruitedMind(datum/mind/M, laterole)
	var/datum/role/newRole = ..()
	if(!newRole)
		return
	num_agents++
	newRole.OnPostSetup()

/datum/faction/abductors/proc/get_needed_teamrole()
	. = FALSE
	if(num_scientists > 0)
		. = num_scientists > num_agents

/datum/faction/abductors/can_setup()
	if(!..())
		return FALSE
	name = "Mothership"
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
