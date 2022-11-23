/datum/game_mode/syndirevolution
	name = "Syndicate Revolution"
	config_name = "syndirevolution"
	probability = 80

	factions_allowed = list(/datum/faction/revolution/flash_revolution)

	minimum_player_count = 25
	minimum_players_bundles = 25

/datum/game_mode/syndireva/announce()
	to_chat(world, "<B>The current game mode is - Syndicate Revolution!</B>")
	to_chat(world, "<B>Someone on the station is a Syndicate agent with a tool to brainwash the crew! They are going to start a revolution!</B>")
