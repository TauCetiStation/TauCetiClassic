/datum/game_mode/imposter
	name = "Imposter"
	config_name = "imposter"
	// Not one faction because faction-oriented code of roles
	factions_allowed = list(/datum/faction/traitor/imposter, \
	                        /datum/faction/changeling/imposter, \
							/datum/faction/cult/heretics)
	minimum_player_count = 10
	minimum_players_bundles = 20

/datum/game_mode/amogus/announce()
	to_chat(world, "<B>The current game mode is - Imposter!</B>")
	to_chat(world, "<B>There is a imposter on the station!</B>")
