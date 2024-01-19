var/global/list/datum/light_mode/light_modes_by_type
var/global/list/datum/light_mode/light_modes_by_name // for admins, may differ in content from light_modes_by_type

#define DEFAULT_RANGE 7
#define DEFAULT_POWER 0.8

/datum/light_mode
	var/name

	var/color
	var/power
	var/range // minimum is 1.4, see MINIMUM_USEFUL_LIGHT_RANGE

/datum/light_mode/New()
	if(!name) // don't check admin created modes
		return
	// todo: we can adjust color and calculate power from difference
	var/adjusted_color = adjust_to_white(color)
	if(adjusted_color != color)
		WARNING("Light mode \"[name]\" ([type]) color \"[color]\" is too dark! Please use adjusted color: \"[adjusted_color]\", and change darkness with \"power\"/\"range\" parameters!")


/* Defaults for old dumb lamps */

/datum/light_mode/default
	name = "Default"

	color = "#faf6ff"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/default/bulb
	name = "Default Bulb"

	color = "#ffaa66"
	power = DEFAULT_POWER
	range = 4

/datum/light_mode/default/bulb/emergency
	name = "Default Emergency"

	color = "#ff272a"
	power = DEFAULT_POWER
	range = 6

/datum/light_mode/default/spot // check range, only for cenctomm lamps!
	name = "Default Spot"

	range = 12
	power = DEFAULT_POWER

/datum/light_mode/default/dim // default fallback mode, if something was broken with smartlight code
	name = "Default Dim"

	power = 0.5
	range = 4

/* Department light */

/datum/light_mode/rnd
	name = "RnD"

	//color = "#e3cddf"
	color = "#ffddff"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/medbay
	name = "MedBay"

	color = "#e8e9ff"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/brig
	name = "Brig"

	color = "#ffeedd"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/brig/dark
	name = "Dark Brig"

	power = 0.7
	range = 6

/datum/light_mode/engineering
	name = "Engineering"

	//color = "#f3e9ca"
	color = "#fff5d6"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/cargo
	name = "Cargo"

	//color = "#eee1d3"
	color = "#fff2e4"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/* Customs for new smart lamps */

/datum/light_mode/soft
	name = "Soft"

	color = "#ffe4c9"
	power = DEFAULT_POWER //todo: ex-nightshift, should we adapt another for day ?
	range = DEFAULT_RANGE

/datum/light_mode/hard
	name = "Hard"

	color = "#e8e9ff"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/k3000
	name = "3000k"

	color = "#ffb46b"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/k4000
	name = "4000k"

	color = "#ffd1a3"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/k5000
	name = "5000k"

	color = "#ffe4ce"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/k6000
	name = "6000k"

	color = "#fff3ef"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/shadows_soft
	name = "Shadows Soft"

	color = "#ffe4c9"
	power = 0.5
	range = 5

/datum/light_mode/shadows_hard
	name = "Shadows Hard"

	color = "#e8e9ff"
	power = 0.5
	range = 5

/datum/light_mode/horror
	name = "Horror"

	color = "#e8e9ff"
	power = 0.5
	range = 4

/datum/light_mode/code_red
	name = "Code Red"

	//color = "#690101"
	color = "#ff9797"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/blue_night
	name = "Blue Night"

	//color = "#22566a"
	color = "#b7ebff"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/soft_blue
	name = "Soft Blue"

	//color = "#009eda"
	color = "#25c3ff"
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/neon
	name = "Neon"

	//color = "#b77ad0"
	color = "#e6a9ff"
	power = DEFAULT_POWER
	range = 6

/datum/light_mode/neon_dark
	name = "Neon Dark"

	//color = "#a339ce"
	color = "#d46aff"
	power = DEFAULT_POWER
	range = 6

/datum/light_mode/code_delta
	name = "Code Delta"

	color = "#ff0915"
	power = DEFAULT_POWER
	range = 6

#undef DEFAULT_RANGE
#undef DEFAULT_POWER
