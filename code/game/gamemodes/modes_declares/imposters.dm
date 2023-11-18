/datum/game_mode/imposter
	name = "Imposter"
	config_name = "imposter"
	probability = 5
	factions_allowed = list(/datum/faction/traitor/auto/imposter)
	minimum_player_count = 1
	minimum_players_bundles = 1

/datum/game_mode/imposter/announce()
	to_chat(world, "<B>Текущий режим игры - Самозванец!</B>")
	to_chat(world, "<B>Среди нас 1 предатель...</B>")
