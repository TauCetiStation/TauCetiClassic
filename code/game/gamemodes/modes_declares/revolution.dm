/datum/game_mode/revolution
	name = "Revolution"
	config_name = "revolution"
	probability = 80

	factions_allowed = list(/datum/faction/revolution)

	minimum_player_count = 4
	minimum_players_bundles = 20

/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!</B>")

/datum/game_mode/syndireva
	name = "Syndicate Revolution"
	config_name = "syndirevolution"
	probability = 80

	factions_allowed = list(/datum/faction/revolution/flash_revolution)

	minimum_player_count = 1
	minimum_players_bundles = 1

/datum/game_mode/syndireva/announce()
	to_chat(world, "<B>Aboba The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!</B>")
