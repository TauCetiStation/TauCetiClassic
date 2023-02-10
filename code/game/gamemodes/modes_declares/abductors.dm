/datum/game_mode/abduction
	name = "Abduction"
	config_name = "abduction"
	probability = 50
	factions_allowed = list(/datum/faction/abductors = 4)

	minimum_player_count = 25
	minimum_players_bundles = 25

/datum/game_mode/abduction/proc/setup_landmarks()
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

/datum/game_mode/abduction/SetupFactions()
	var/abductor_teams = clamp(round(get_player_count(TRUE) / ABDUCTOR_SCALING_COEFF), 1, MAX_ABDUCTOR_TEAMS)
	factions_allowed[/datum/faction/abductors] = abductor_teams

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [station_name()] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")
