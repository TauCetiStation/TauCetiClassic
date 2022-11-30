/datum/game_mode/zombie_malf
	name = "Zombie Malfunction"
	config_name = "zombie_malf"
	probability = 100

	factions_allowed = list(/datum/faction/malf_silicons/zombie)

	minimum_player_count = 30
	minimum_players_bundles = 30

/datum/game_mode/zombie_malf/announce()
	to_chat(world, "<B>The current game mode is - Zombie Malfunction!</B>")
	to_chat(world, "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>")
	to_chat(world, "After first hacking the systems, the AI will be able to spread the zombie virus. By capturing the station, he will be able to create killer cyborgs.")
