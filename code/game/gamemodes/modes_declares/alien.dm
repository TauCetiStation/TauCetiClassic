/datum/game_mode/alien
	name = "Alien"
	config_name = "alien"
	probability = 100

	factions_allowed = list(/datum/faction/alien)

	minimum_player_count = 0
	minimum_players_bundles = 6

/datum/game_mode/alien/announce()
	to_chat(world, "<b>Текущий режим игры - Чужой!</b>")
	to_chat(world, "<b>Это <span class='userdanger'>Ксеноморф</span> на корабле. Экипаж: Убейте эту тварь как можно скорее.</b>")
