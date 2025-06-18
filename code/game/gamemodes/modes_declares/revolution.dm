/datum/game_mode/revolution
	name = "Revolution"
	config_name = "revolution"
	probability = 80

	factions_allowed = list(/datum/faction/revolution)

	minimum_player_count = 4
	minimum_players_bundles = 20

/datum/game_mode/revolution/announce()
	to_chat(world, "<B>Текущий режим игры - Революция!</B>")
	to_chat(world, "<B>Некоторые члены экипажа попытаются устроить революцию!</B>")
