/datum/game_mode/malfunction
	name = "AI Malfunction"
	config_name = "malf"
	probability = 80

	factions_allowed = list(/datum/faction/malf_silicons)

	minimum_player_count = 1
	minimum_players_bundles = 20

/datum/game_mode/malfunction/announce()
	to_chat(world, "<B>Текущий режим игры - Неисправный ИИ!</B>")
	to_chat(world, "<B>ИИ на спутнике дал сбой и должен быть уничтожен.</B>")
	to_chat(world, "Спутник ИИ находится глубоко в космосе, и добраться до него можно только с помощью телепортера! У вас есть [1800/60] минут, чтобы отключить ИИ.")
