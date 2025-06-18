/datum/game_mode/blob
	name = "Blob"
	config_name = "blob"
	probability = 50
	factions_allowed = list(/datum/faction/blob_conglomerate)

	minimum_player_count = 25
	minimum_players_bundles = 25

/datum/game_mode/blob/announce()
	to_chat(world, "<B>Текущий режим игры - <font color='green'>Блоб</font>!</B>")
	to_chat(world, "<B>Опасный инопланетный организм стремительно распространяется по станции!</B>")
	to_chat(world, "Вы должны уничтожить его полностью, минимизировав при этом ущерб станции.")
