var/global/list/datum/light_mode/light_modes_by_type
var/global/list/datum/light_mode/light_modes_by_name // for admins, may differ in content from light_modes_by_type

#define DEFAULT_RANGE 8
#define DEFAULT_POWER 2

/datum/light_mode
	var/name

	var/color
	var/power
	var/range // minimum is 1.4, see MINIMUM_USEFUL_LIGHT_RANGE


/* Defaults for old dumb lamps */

/datum/light_mode/default
	name = "Default"

	color = "#ffffff" // todo: replace with softer light (6500К - #FFF9FD?)
	power = DEFAULT_POWER
	range = DEFAULT_RANGE

/datum/light_mode/default/bulb
	name = "Default Bulb"

	color = "#a0a080"
	power = DEFAULT_POWER
	range = 4

/datum/light_mode/default/bulb/emergency
	name = "Default Emergency"

	color = "#da0205"
	power = DEFAULT_POWER
	range = 6

/datum/light_mode/default/spot // check range, only for cenctomm lamps!
	name = "Default Spot"

	range = 12
	power = DEFAULT_POWER
	power = 4

/datum/light_mode/default/dim
	name = "Default Dim"

	power = 0.5
	range = 4

/* Customs for new smart lamps */

/datum/light_mode/soft
	name = "Soft"

	color = "#ffe4c9"
	power = 0.8 //todo: ex-nightshift, should we adapt another for day ?
	range = DEFAULT_RANGE

/datum/light_mode/hard
	name = "Hard"

	color = "#e8e9ff"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/k3000
	name = "3000k"

	color = "#ffb46b"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/k4000
	name = "4000k"

	color = "#ffd1a3"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/k5000
	name = "5000k"

	color = "#ffe4ce"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/k6000
	name = "6000k"

	color = "#fff3ef"
	power = 0.8
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

	color = "#690101"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/blue_night
	name = "Blue Night"

	color = "#22566a"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/soft_blue
	name = "Soft Blue"

	color = "#009eda"
	power = 0.8
	range = DEFAULT_RANGE

/datum/light_mode/neon
	name = "Neon"

	color = "#b77ad0"
	power = 0.8
	range = 6

/datum/light_mode/neon_dark
	name = "Neon Dark"

	color = "#a339ce"
	power = 0.8
	range = 6

#undef DEFAULT_RANGE
#undef DEFAULT_POWER
