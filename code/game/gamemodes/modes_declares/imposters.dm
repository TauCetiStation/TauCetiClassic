/datum/game_mode/imposter
	name = "Imposter"
	config_name = "imposter"
	probability = 70
	factions_allowed = list(/datum/faction/traitor/auto/imposter)
	minimum_player_count = 1
	minimum_players_bundles = 1

/datum/game_mode/amogus/announce()
	to_chat(world, "<B>The current game mode is - Imposter!</B>")
	to_chat(world, "<B>There is a imposter on the station!</B>")
