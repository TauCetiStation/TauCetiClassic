/datum/game_mode/malfunction
	name = "AI Malfunction"
	config_name = "malf"
	probability = 80

	factions_allowed = list(/datum/faction/malf_silicons)

	minimum_player_count = 1
	minimum_players_bundles = 20

/datum/game_mode/malfunction/announce()
	to_chat(world, "<B>The current game mode is - AI Malfunction!</B>")
	to_chat(world, "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>")
	to_chat(world, "The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have [1800/60] minutes to disable it.")
