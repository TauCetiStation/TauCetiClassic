/datum/game_mode/mutiny
	name = "Mutiny"
	config_name = "mutiny"
	probability = 80

	factions_allowed = list(/datum/faction/loyalists)
	//TODO: 4 20
	minimum_player_count = 1
	minimum_players_bundles = 1

/datum/game_mode/mutiny/announce()
	to_chat(world, "<B>The current game mode is - Mutiny!</B>")
	to_chat(world, "<B>Loyal heads are attempting to start a tyrany!</B>")
