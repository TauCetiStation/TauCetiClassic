var/global/list/smartlight_presets

/datum/smartlight_preset
	var/name // for map configs mostly, also for APC with custom settings

	var/default_mode
	var/nightshift_mode

	var/no_nightshift_mode = FALSE // for area APC

	var/list/available_modes = list()
	var/list/disabled_modes = list()

/datum/smartlight_preset/proc/get_user_available_modes()
	. = list()
	for(var/type in (available_modes - disabled_modes))
		var/datum/light_mode/LM = global.light_modes_by_type[type]
		.[LM.name] = LM

	return .

/datum/smartlight_preset/proc/disable_mode(path)
	if(path in available_modes)
		disabled_modes += path
		return TRUE

/datum/smartlight_preset/proc/enable_mode(path)
	if(path in disabled_modes)
		disabled_modes -= path
		return TRUE

/datum/smartlight_preset/proc/add_mode(path, disabled = FALSE)
	if(path in available_modes)
		return FALSE

	available_modes += path
	if(disabled)
		disabled_modes += path
	return TRUE

// expand default station preset (base) with custom APC preset (src)
/datum/smartlight_preset/proc/expand_onto(datum/smartlight_preset/base)
	name = "[base.name][name ? " [name]" : ""]"

	default_mode = default_mode ? default_mode : base.default_mode
	if(!no_nightshift_mode)
		nightshift_mode = nightshift_mode ? nightshift_mode : base.nightshift_mode
	available_modes = base.available_modes | available_modes
	disabled_modes = base.disabled_modes | disabled_modes

/*
   Global Map presets
*/

/datum/smartlight_preset/default
	name = "default"

	default_mode = /datum/light_mode/default
	//nightshift_mode = /datum/light_mode/soft

	nightshift_mode = /datum/light_mode/default
	no_nightshift_mode = TRUE

	available_modes = list(
		/datum/light_mode/default,
		/datum/light_mode/k3000,
		/datum/light_mode/k4000,
		/datum/light_mode/k5000,
		/datum/light_mode/k6000,
		/datum/light_mode/soft,
		/datum/light_mode/hard,
	)

/datum/smartlight_preset/horror_station // emag preset
	name = "horror"

	default_mode = /datum/light_mode/horror
	no_nightshift_mode = TRUE

	available_modes = list(
		/datum/light_mode/horror,
	)

/*
   Local APC presets (will expand global one)
*/

/datum/smartlight_preset/bar
	name = "bar"

	default_mode = /datum/light_mode/default
	no_nightshift_mode = TRUE

	available_modes = list(
		/datum/light_mode/blue_night,
		/datum/light_mode/soft_blue,
		/datum/light_mode/neon,
		/datum/light_mode/neon_dark,
	)

// todo: maybe need to be replaced with custom_smartlight_preset for APC in areas
/*var/global/hard_lighting_arealist = typecacheof(typesof(/area/station/medical) + typesof(/area/station/rnd) + typesof(/area/asteroid/research_outpost))

/datum/smartlight_preset/hardlight_nightshift
	name = "operating nightshift"

	nightshift_mode = /datum/light_mode/hard
	available_modes = list(/datum/light_mode/hard)*/

/datum/smartlight_preset/rnd
	name = "RnD"

	default_mode = /datum/light_mode/rnd
	no_nightshift_mode = TRUE

	available_modes = list(/datum/light_mode/rnd)

/datum/smartlight_preset/medbay
	name = "MedBay"

	default_mode = /datum/light_mode/medbay
	no_nightshift_mode = TRUE

	available_modes = list(/datum/light_mode/medbay)

/datum/smartlight_preset/brig
	name = "Brig"

	default_mode = /datum/light_mode/brig
	no_nightshift_mode = TRUE

	available_modes = list(
							/datum/light_mode/brig,
							/datum/light_mode/brig/dark,
	)

/datum/smartlight_preset/brig/dark
	name = "Dark Brig"

	default_mode = /datum/light_mode/brig/dark
	no_nightshift_mode = TRUE

	available_modes = list(
							/datum/light_mode/brig,
							/datum/light_mode/brig/dark,
	)

/datum/smartlight_preset/engineering
	name = "Engineering"

	default_mode = /datum/light_mode/engineering
	no_nightshift_mode = TRUE

	available_modes = list(/datum/light_mode/engineering)

/datum/smartlight_preset/cargo
	name = "Cargo"

	default_mode = /datum/light_mode/cargo
	no_nightshift_mode = TRUE

	available_modes = list(/datum/light_mode/cargo)

/datum/smartlight_preset/k3000
	name = "default 3000k"
	default_mode = /datum/light_mode/k3000
	no_nightshift_mode = TRUE
	available_modes = list(/datum/light_mode/k3000)

/datum/smartlight_preset/k4000
	name = "default 4000k"
	default_mode = /datum/light_mode/k4000
	no_nightshift_mode = TRUE
	available_modes = list(/datum/light_mode/k4000)

/datum/smartlight_preset/k5000
	name = "default 5000k"
	default_mode = /datum/light_mode/k5000
	no_nightshift_mode = TRUE
	available_modes = list(/datum/light_mode/k5000)

/datum/smartlight_preset/k6000
	name = "default 6000k"
	no_nightshift_mode = TRUE
	default_mode = /datum/light_mode/k6000
	no_nightshift_mode = TRUE
	available_modes = list(/datum/light_mode/k6000)

/datum/smartlight_preset/soft
	name = "soft"
	default_mode = /datum/light_mode/soft
	no_nightshift_mode = TRUE
	available_modes = list(/datum/light_mode/soft)

/datum/smartlight_preset/hard
	name = "hard"
	default_mode = /datum/light_mode/hard
	no_nightshift_mode = TRUE
	available_modes = list(/datum/light_mode/hard)
