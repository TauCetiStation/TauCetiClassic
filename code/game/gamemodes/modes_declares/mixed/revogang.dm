/datum/game_mode/mix/revogang
	name = "Revolution+Families"
	config_name = "revogang"
	probability = 100
	factions_allowed = list(
		/datum/faction/cops,
		/datum/faction/revolution,
	)

	minimum_player_count = 40
	minimum_players_bundles = 40

	var/gangs_to_generate = 2

/datum/game_mode/mix/revogang/SetupFactions()
	var/list/gangs_to_use = subtypesof(/datum/faction/gang)
	for(var/i in 1 to gangs_to_generate)
		factions_allowed += pick_n_take(gangs_to_use)
