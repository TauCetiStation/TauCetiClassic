/datum/game_mode/extended
	name = "Extended"
	config_name = "extended"
	probability = 30
	minimum_player_count = 0

/datum/game_mode/extended/announce()
	to_chat(world, "<B>The current game mode is - Extended Role-Playing!</B>")
	to_chat(world, "<B>Just have fun and role-play!</B>")

/datum/game_mode/extended/Setup()
	return TRUE
