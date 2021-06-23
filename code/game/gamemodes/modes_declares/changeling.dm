/datum/game_mode/changeling
	name = "Changeling"
	config_name = "changeling"
	probability = 100
	factions_allowed = list(/datum/faction/changeling)

	minimum_player_count = 2
	minimum_players_bundles = 20

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>The current game mode is - Changeling!</B>")
	to_chat(world, "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>")
