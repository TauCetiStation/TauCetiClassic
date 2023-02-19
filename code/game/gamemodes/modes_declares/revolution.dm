/datum/game_mode/revolution
	name = "Revolution"
	config_name = "revolution"
	probability = 80

	factions_allowed = list(/datum/faction/revolution)

	minimum_player_count = 4
	minimum_players_bundles = 20

/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Someone on the station is a Syndicate agent with a tool to brainwash the crew! They are going to start a revolution!</B>")
