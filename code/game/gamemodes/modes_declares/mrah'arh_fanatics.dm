/datum/game_mode/fanatics
	name = "Mrah'arh's Fanatics"
	config_name = "fanatics"
	probability = 100

	factions_allowed = list(/datum/faction/fanatics)

	minimum_player_count = 15
	minimum_players_bundles = 20

/datum/game_mode/fanatics/announce()
	to_chat(world, "<b>Текущий режим игры - фанатики Мра'арха, уничтожителя миров!</b>")
	to_chat(world, "<b>Не спутайте их с другими любителями кровавого колдунства!</b>")
