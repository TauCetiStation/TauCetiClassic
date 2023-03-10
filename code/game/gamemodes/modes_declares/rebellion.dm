/datum/game_mode/rebellion
	name = "Rebellion"
	config_name = "rebellion"
	probability = 80

	factions_allowed = list(/datum/faction/loyalists)

	//TODO 4:20
	minimum_player_count = 1
	minimum_players_bundles = 1

/datum/game_mode/rebellion/announce()
	to_chat(world, "<B>The current game mode is - Rebellion!</B>")
	to_chat(world, "<B>Loyal heads are attempting to start a tyrany!</B>")
