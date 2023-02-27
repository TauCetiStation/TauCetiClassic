/datum/game_mode/replicators
	name = "Replicators"
	config_name = "replicators"
	probability = 100

	factions_allowed = list(/datum/faction/replicators)

	minimum_player_count = 25
	minimum_players_bundles = 35

/datum/game_mode/infestation/announce()
	to_chat(world, "<b>The current game mode is - Replicators!</b>")
	to_chat(world, "<b>There are <span class='userdanger'>Replicators</span> on the station. Crew: Eradicate replicators before they build a bluespace catapult. Replicators: CONSUME. CONSUME. CONSUME.</b>")
