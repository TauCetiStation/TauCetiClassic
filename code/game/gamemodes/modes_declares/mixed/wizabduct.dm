/datum/game_mode/mix/wizabduct
	name = "Visitors"
	config_name = "visitors"
	probability = 80
	factions_allowed = list(
		/datum/faction/wizards = 1,
		/datum/faction/abductors = 4,
	)

	minimum_player_count = 50
	minimum_players_bundles = 50

/datum/game_mode/mix/wizabduct/SetupFactions()
	var/abductor_teams = clamp(round(num_players() / ABDUCTOR_SCALING_COEFF), 1, MAX_ABDUCTOR_TEAMS)
	var/possible_teams = max(1, round(get_player_count() / 2))
	abductor_teams = min(abductor_teams, possible_teams)
	factions_allowed[/datum/faction/abductors] = abductor_teams
