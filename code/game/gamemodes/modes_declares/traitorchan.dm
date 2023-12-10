/datum/game_mode/traitorchan
	name = "TraitorChan"
	config_name = "traitorchan"
	probability = 50
	factions_allowed = list(
		/datum/faction/changeling/traitorchan,
		/datum/faction/traitor,
	)

	minimum_player_count = 20
	minimum_players_bundles = 45

/datum/game_mode/traitorchan/announce()
	to_chat(world, "<B>Текущий режим игры - Предатели-Генокрады!</B>")
	to_chat(world, "<B>На станции находится инопланетное существо, а также несколько оперативников Синдиката, преследующих свои цели! Не дайте генокраду и предателям добиться успеха!</B>")
