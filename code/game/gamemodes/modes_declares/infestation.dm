/datum/game_mode/infestation
	name = "Infestation"
	config_name = "infestation"
	probability = 100

	factions_allowed = list(/datum/faction/infestation)

	minimum_player_count = 25
	minimum_players_bundles = 35

/datum/game_mode/infestation/announce()
	to_chat(world, "<b>The current game mode is - Infestation!</b>")
	to_chat(world, "<b>There are <span class='userdanger'>xenomorphs</span> on the station. Crew: Kill the xenomorphs before they infest the station. Xenomorphs: Go catch some living hamburgers.</b>")
