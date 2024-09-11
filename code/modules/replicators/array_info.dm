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
	var/corridor_crossed_times = 0

	var/catapults_built = 0

	var/disintegrated_entities = 0

	var/mine_triggers = 0

	var/replicators_screwed = 0

	var/eaten_humans = 0

	var/objections_received = 0

/datum/replicator_array_info/New(datum/faction/replicators/faction)
	var/letter_number = length(faction.ckey2info) % length(greek_pronunciation) + 1
	var/magnitude = 1 + round(length(faction.ckey2info) / (length(greek_pronunciation) - 1))
	var/magnitude_string = ""
	for(var/i in 1 to magnitude)
		magnitude_string += "[rand(0, 9)]"

	presence_name = greek_pronunciation[letter_number] + "-[magnitude_string] Presence"
	array_color = pick(REPLICATOR_COLORS)

/datum/replicator_array_info/proc/get_array_units(datum/faction/replicators/faction)
	. = list()
	for(var/mob/living/simple_animal/hostile/replicator/R as anything in global.alive_replicators)
		if(faction.ckey2info[R.last_controller_ckey] == src)
			. += R
