/datum/game_mode/shadowling
	name = "Shadowling"
	config_name = "shadowling"
	probability = 70

	factions_allowed = list(/datum/faction/shadowlings)

	minimum_player_count = 30
	minimum_players_bundles = 25

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>The current game mode is - Shadowling!</b>")
	to_chat(world, "<b>There are alien <span class='userdanger'>shadowlings</span> on the station. Crew: Kill the shadowlings before they can eat or enthrall the crew. Shadowlings: Enthrall the crew while remaining in hiding.</b>")
