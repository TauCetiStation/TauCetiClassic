var/global/list/datum/level_lighting_effect/lighting_effects

/datum/level_lighting_effect
	var/name
	var/list/colors = list()
	var/transition_delay
	// if no other effects should change color later
	var/lock_after = FALSE
	// if should change to pre-effect color
	var/reset_after = FALSE

/* space lighting */
/datum/level_lighting_effect/starlight
	name = "starlight"
	colors = list("#4c6c8d")

/datum/level_lighting_effect/centcomm
	name = "centcomm"
	colors = list("#75499d")

/* events */
/datum/level_lighting_effect/narsie
	name = "narsie"
	colors = list("#444444", "#222222", "#af243a")
	transition_delay = 15 SECONDS
	reset_after = FALSE
	lock_after = TRUE

/* aurora */
/datum/level_lighting_effect/random_aurora
	name = "random aurora"
	reset_after = TRUE
	transition_delay = 5 SECONDS

/datum/level_lighting_effect/random_aurora/New(duration = 60 SECONDS)
	var/transitions = ceil(duration/transition_delay)
	for(var/i in 1 to transitions)
		colors += list(color_lightness_max(random_color(), 0.70))

/* Planetary lighting */
/datum/level_lighting_effect/snow_map_random
	name = "snow map random"
	colors = list("#13131f", "#363b4c", "#ebfffa", "#806963") // not yellow snow pls

/datum/level_lighting_effect/snow_map_random/New()
	colors = list(pick(colors))

/datum/level_lighting_effect/junkyard
	name = "junkyard"
	colors = list("#5f5f5f") // junkyard is already colorful, gray to add darkness works better
