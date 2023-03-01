/datum/replicator_array_info
	var/presence_name = ""
	var/array_color = "#ffffff"
	var/swarms_goodwill = 0

	var/next_music_start = 0

	var/replicators_launched = 0

	var/replicated_times = 0
	var/transponders_built = 0
	var/generators_built = 0
	var/barricades_built = 0
	var/traps_built = 0
	var/corridors_constructed = 0

	var/catapults_built = 0

	var/disintegrated_entities = 0

/datum/replicator_array_info/New(datum/faction/replicators/faction)
	presence_name = greek_pronunciation[length(faction.members)] + "-[rand(0, 9)] Presence"
	array_color = pick(REPLICATOR_COLORS)
