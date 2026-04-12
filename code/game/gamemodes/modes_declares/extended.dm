/datum/game_mode/extended
	name = "Extended"
	config_name = "extended"
	probability = 40
	minimum_player_count = 0

/datum/game_mode/extended/announce()
	to_chat(world, "<B>Текущий режим игры - Extended, Ролевая игра!</B>")
	to_chat(world, "<B>Просто веселитесь и играйте!</B>")
