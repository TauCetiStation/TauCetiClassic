/datum/game_mode/traitorchan
	name = "TraitorChan"
	factions_allowed = list(/datum/faction/traitor/traitorchan)
	minimum_player_count = 3
	minimum_players_bundles = 25

/datum/game_mode/traitorchan/announce()
	to_chat(world, "<B>The current game mode is - [name]!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")
