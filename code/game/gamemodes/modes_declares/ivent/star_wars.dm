/datum/game_mode/ivent/star_wars
	name = "Star Wars"
	config_name = "star_wars"

	factions_allowed = list(/datum/faction/star_wars/jedi, /datum/faction/star_wars/sith)

/datum/game_mode/ivent/star_wars/announce()
	to_chat(world, "<B>Текущий режим игры - Звёздные Войны!</B>")
	to_chat(world, "<B>На станции развернётся противостояние ситхов и джедаев!</B>")

/datum/game_mode/ivent/star_wars/Setup()

