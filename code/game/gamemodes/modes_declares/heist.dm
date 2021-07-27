
/datum/game_mode/heist
	name = "Heist"
	config_name = "heist"
	probability = 80

	factions_allowed = list(/datum/faction/heist)

	minimum_player_count = 15
	minimum_players_bundles = 15

/datum/game_mode/heist/announce()
	to_chat(world, "<B>The current game mode is - Heist!</B>")
	to_chat(world, "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>")
	to_chat(world, "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!")
	to_chat(world, "<B>Raiders:</B> Loot [station_name()] for anything and everything you need.")
	to_chat(world, "<B>Personnel:</B> Repel the raiders and their low, low prices and/or crossbows.")
