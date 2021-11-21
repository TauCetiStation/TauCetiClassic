/datum/game_mode/revolution
	name = "Revolution"
	config_name = "revolution"
	probability = 80

	factions_allowed = list(/datum/faction/revolution)

	minimum_player_count = 1
	minimum_players_bundles = 20

/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!</B>")
