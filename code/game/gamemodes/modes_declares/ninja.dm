/datum/game_mode/ninja
	name = "Ninja"

	factions_allowed = list(/datum/faction/ninja)

	minimum_player_count = 10
	minimum_players_bundles = 15

/datum/game_mode/ninja/announce()
	to_chat(world, "<B>The current game mode is Ninja!</B>")
