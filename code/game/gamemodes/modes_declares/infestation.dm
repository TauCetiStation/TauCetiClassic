/datum/game_mode/infestation
	name = "Infestation"
	config_name = "infestation"
	probability = 100

	factions_allowed = list(/datum/faction/infestation)

	minimum_player_count = 25
	minimum_players_bundles = 35

/datum/game_mode/infestation/announce()
	to_chat(world, "<b>Текущий режим игры - Заражение!</b>")
	to_chat(world, "<b>Это <span class='userdanger'>ксеноморфы</span> на станции. Экипаж: Убейте ксеноморфов, пока они не заселили всю станцию. Ксеноморфы: Идите и ловите живые гамбургеры.</b>")
