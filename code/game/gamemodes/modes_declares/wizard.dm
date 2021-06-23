/datum/game_mode/wizard
	name = "Wizard"
	config_name = "wizard"
	probability = 80
	factions_allowed = list(/datum/faction/wizards)

	minimum_player_count = 2
	minimum_players_bundles = 10

/datum/game_mode/wizard/announce()
	to_chat(world, "<B>The current game mode is - Wizard!</B>")
	to_chat(world, "<B>There is a <span class='warning'>SPACE WIZARD</span> on the station. You can't let him achieve his objective!</B>")
