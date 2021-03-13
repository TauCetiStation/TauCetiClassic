#define ABDUCTOR_SCALING_COEFF 15 //how many players per abductor team
#define MAX_ABDUCTOR_TEAMS 4

/datum/game_mode/abduction
	name = "Abduction"
	factions_allowed = list(/datum/faction/abductors = 4)

	minimum_player_count = 0
	minimum_players_bundles = 25

/datum/game_mode/abduction/proc/setup_landmarks()
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

/datum/game_mode/abduction/SetupFactions()
	var/players = get_player_count()
	var/abductor_teams = max(1, min(MAX_ABDUCTOR_TEAMS, round(num_players() / ABDUCTOR_SCALING_COEFF)))
	var/possible_teams = max(1, round(players / 2))
	abductor_teams = min(abductor_teams,possible_teams)
	factions_allowed[/datum/faction/abductors] = abductor_teams

	setup_landmarks()

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [station_name()] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

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

#undef ABDUCTOR_SCALING_COEFF
