/datum/game_mode/rp_revolution
	name = "Revolution"

	factions_allowed = list(/datum/faction/revolution)

	minimum_player_count = 4
	minimum_players_bundles = 20

	newscaster_announcements = /datum/news_announcement/revolution_inciting_event

/datum/game_mode/rp_revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!</B>")
