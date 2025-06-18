/datum/game_mode/traitor
	name = "Traitor"
	config_name = "traitor"
	probability = 80
	factions_allowed = list(/datum/faction/traitor)

	minimum_player_count = 1
	minimum_players_bundles = 1

/datum/game_mode/traitor/announce()
	to_chat(world, "<B>Текущий режим игры - Предатели!</B>")
	to_chat(world, "<B>На станции находятся агенты Cиндиката. Не дайте агентам добиться успеха!</B>")
