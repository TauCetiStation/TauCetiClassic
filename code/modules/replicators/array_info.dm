/datum/replicator_array_info
	var/presence_name = ""
	var/array_color = "#ffffff"
	var/swarms_goodwill = 0

	var/next_music_start = 0

	var/replicators_launched = 0

/datum/replicator_array_info/New(datum/faction/replicators/faction)
	presence_name = greek_pronunciation[length(faction.members)] + "-[rand(0, 9)] Presence"
	array_color = pick(REPLICATOR_COLORS)
