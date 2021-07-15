/datum/game_mode/families
	name = "Families"
	config_name = "families"
	probability = 100

	//factions_allowed = list(/datum/faction/cops)
	factions_allowed = list()

	minimum_player_count = 0
	minimum_players_bundles = 0

	var/gangs_to_generate = 3

/datum/game_mode/families/SetupFactions()
	var/list/gangs_to_use = subtypesof(/datum/faction/gang)
	for(var/i in 1 to gangs_to_generate)
		factions_allowed += pick_n_take(gangs_to_use)
	factions_allowed += /datum/faction/cops

/datum/game_mode/families/announce()
	to_chat(world, "<B>Текущий режим игры - Семьи!</B>")
