/datum/game_mode/traitorchan
	name = "TraitorChan"
	config_name = "traitorchan"
	probability = 50
	factions_allowed = list(
		/datum/faction/changeling/traitorchan,
		/datum/faction/traitor,
	)

	minimum_player_count = 20
	minimum_players_bundles = 45

/datum/game_mode/traitorchan/announce()
	to_chat(world, "<B>The current game mode is - [name]!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")
