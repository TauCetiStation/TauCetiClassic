/datum/game_mode/nuclear
	name = "Nuclear Emergency"
	config_name = "nuke"
	probability = 100

	factions_allowed = list(/datum/faction/nuclear)

	minimum_player_count = 15
	minimum_players_bundles = 25

/datum/game_mode/nuclear/PopulateFactions()
	if(!factions.len)
		return ..()
	var/list/all_players = get_ready_players(check_ready = TRUE)
	var/number_of_possible_security = 0
	var/pos_cadets = 0
	for(var/mob/M in all_players)
		for(var/level in JP_LEVELS)
			if(M.client?.prefs?.job_preferences["Security Cadet"] == level)
				pos_cadets += level / 3
				break
	var/pos_officers = 0
	for(var/mob/M in all_players)
		for(var/level in JP_LEVELS)
			if(M.client?.prefs?.job_preferences["Security Officer"] == level)
				pos_officers += level / 3
				break
	number_of_possible_security = pos_cadets / 2 + pos_officers
	for(var/datum/faction/F in factions)
		var/possible_max_roles = min(number_of_possible_security * 1.5, F.max_roles)
		F.max_roles = clamp(possible_max_roles, F.min_roles, F.max_roles)
	return ..()

/datum/game_mode/nuclear/announce()
	to_chat(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	to_chat(world, "<B>Gorlex Maradeurs are approaching [station_name()]!</B>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!")
