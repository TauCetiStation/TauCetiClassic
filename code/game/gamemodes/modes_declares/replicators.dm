/datum/game_mode/replicators
	name = "Replicators"
	config_name = "replicators"
	probability = 100

	factions_allowed = list(/datum/faction/replicators)

	minimum_player_count = 25
	minimum_players_bundles = 35

/datum/game_mode/replicators/announce()
	to_chat(world, "<b>Текущий режим игры - Репликаторы!</b>")
	to_chat(world, "<b>Это <span class='userdanger'>репликаторы</span> на станции. Экипаж: Уничтожьте репликаторов до того, как они создадут блюспейс катапульту. Репликаторы: ПОТРЕБЛЯТЬ. ПОТРЕБЛЯТЬ. ПОТРЕБЛЯТЬ.</b>")
