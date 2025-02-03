/datum/game_mode/heretics
	name = "Heretics"
	config_name = "heretics"
	probability = 100

	factions_allowed = list(/datum/faction/heretic)

	minimum_player_count = 15
	minimum_players_bundles = 20

/datum/game_mode/heretics/announce()
	to_chat(world, "<b>Текущий режим игры - еретики, грязные книжные черви!</b>")
