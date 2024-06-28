/datum/game_mode/alien
	name = "Alien"
	config_name = "alien"
	probability = 100

	factions_allowed = list(/datum/faction/alien, /datum/faction/nostromo_crew)

	minimum_player_count = 1
	minimum_players_bundles = 8

/datum/game_mode/alien/announce()
	to_chat(world, "<b>Текущий режим игры - Чужой!</b>")
	to_chat(world, "<b><span class='userdanger'>Ксеноморф</span> на корабле! Экипаж, убейте эту тварь как можно скорее!</b>")
