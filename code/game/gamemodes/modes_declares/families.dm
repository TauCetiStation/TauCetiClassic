/datum/game_mode/families
	name = "Families"
	config_name = "families"
	probability = 100

	factions_allowed = list(/datum/faction/cops)

	minimum_player_count = 30
	minimum_players_bundles = 30

	var/gangs_to_generate = 3

/datum/game_mode/families/SetupFactions()
	var/list/gangs_to_use = subtypesof(/datum/faction/gang)
	for(var/i in 1 to gangs_to_generate)
		factions_allowed += pick_n_take(gangs_to_use)

/datum/game_mode/families/announce()
	to_chat(world, "<B>Текущий режим игры - Семьи!</B>")
