/datum/game_mode/shadowling
	name = "Shadowling"
	config_name = "shadowling"
	probability = 70

	factions_allowed = list(/datum/faction/shadowlings)

	minimum_player_count = 25
	minimum_players_bundles = 25

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>Текущий режим игры - Шедоулинг!</b>")
	to_chat(world, "<b>Это <span class='userdanger'>шедоулинг</span> на станции. Экипаж: Убейте шедоулингов, прежде чем они смогут съесть или подчинить себе экипаж. Шедоулинги: Захватите экипаж, оставаясь в тени.</b>")
