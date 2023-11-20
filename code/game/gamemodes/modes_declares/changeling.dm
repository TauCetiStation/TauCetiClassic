/datum/game_mode/changeling
	name = "Changeling"
	config_name = "changeling"
	probability = 100
	factions_allowed = list(/datum/faction/changeling)

	minimum_player_count = 2
	minimum_players_bundles = 20

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>Текущий режим игры - Генокрад!</B>")
	to_chat(world, "<B>На станции находятся генокрады. Не дайте им добиться успеха!</B>")
