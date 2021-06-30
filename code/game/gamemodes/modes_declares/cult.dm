/datum/game_mode/cult
	name = "Cult Of Blood"
	config_name = "cult"
	probability = 100

	factions_allowed = list(/datum/faction/cult)

	minimum_player_count = 5
	minimum_players_bundles = 20

/datum/game_mode/cult/announce()
	to_chat(world, "<B>Текущий режим игры - Культ!</B>")
	to_chat(world, "<B>Некоторые члены экипажа прибыли на станцию, состоя в культе!</B>")
	to_chat(world, "<B>Культисты - сеют хаос. Заставляйте людей последовать за вами любыми способами. Перемещайте смертных в своё измерение насильно. Запомни - тебя нет, есть только культ.</B>")
	to_chat(world, "<B>Персонал - не знает о культе, но при обнаружении кровавых рун и фанатиков будет сопротивляться. Хороший способ борьбы с фанатиками - это промывка мозгов Библией священника в разрешенную ЦентКомом религию.</B>")
