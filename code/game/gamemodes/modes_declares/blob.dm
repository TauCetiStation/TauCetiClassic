/datum/game_mode/blob
	name = "Blob"
	config_name = "blob"
	probability = 50
	factions_allowed = list(/datum/faction/blob_conglomerate)

	minimum_player_count = 30
	minimum_players_bundles = 25

/datum/game_mode/blob/announce()
	to_chat(world, "<B>The current game mode is - <font color='green'>Blob</font>!</B>")
	to_chat(world, "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>")
	to_chat(world, "You must kill it all while minimizing the damage to the station.")
