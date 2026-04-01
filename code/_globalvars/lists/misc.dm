//added for Xenoarchaeology, might be useful for other stuff
var/global/list/alphabet_uppercase = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")

var/global/list/hex_characters = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")

var/global/list/RESTRICTED_CAMERA_NETWORKS = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"thunder",
	"ERT",
	"NUKE",
	"AURORA",
	"SECURITY UNITS"
	)

// Posters
//var/global/list/datum/poster/poster_designs = subtypesof(/datum/poster)

var/global/list/roles_ingame_minute_unlock = list(
	ROLE_TRAITOR = 720,
	ROLE_OPERATIVE = 2160,
	ROLE_CHANGELING = 2160,
	ROLE_ALIEN = 1440,
	ROLE_WIZARD = 2880,
	ROLE_ERT = 1440,
	ROLE_REV = 1440,
	ROLE_DRONE = 1440,
	ROLE_CULTIST = 3600,
	ROLE_BLOB = 2880,
	ROLE_MALF = 3600,
	ROLE_SHADOWLING = 4320,
	ROLE_FAMILIES = 2160,
	ROLE_REPLICATOR = 2880,
	ROLE_GHOSTLY = 360,
)

var/global/list/datum_alarm_list = list()

var/global/list/all_artifact_effect_types = list(
	/datum/artifact_effect/temperature/cold,
	/datum/artifact_effect/feelings/bad,
	/datum/artifact_effect/cellcharge,
	/datum/artifact_effect/celldrain,
	/datum/artifact_effect/dnaswitch,
	/datum/artifact_effect/emp,
	/datum/artifact_effect/gas,
	/datum/artifact_effect/forcefield,
	/datum/artifact_effect/feelings/good,
	/datum/artifact_effect/heal,
	/datum/artifact_effect/temperature/heat,
	/datum/artifact_effect/hurt,
	/datum/artifact_effect/radiate,
	/datum/artifact_effect/roboheal,
	/datum/artifact_effect/robohurt,
	/datum/artifact_effect/sleepy,
	/datum/artifact_effect/stun,
	/datum/artifact_effect/tesla,
	/datum/artifact_effect/teleport,
	/datum/artifact_effect/light,
	/datum/artifact_effect/light/darkness,
	/datum/artifact_effect/gravity,
	/datum/artifact_effect/noise,
	/datum/artifact_effect/powernet)

var/global/list/valid_primary_effect_types = list(
	/datum/artifact_effect/temperature/cold,
	/datum/artifact_effect/temperature/heat,
	/datum/artifact_effect/dnaswitch,
	/datum/artifact_effect/emp,
	/datum/artifact_effect/gas,
	/datum/artifact_effect/forcefield,
	/datum/artifact_effect/radiate,
	/datum/artifact_effect/sleepy,
	/datum/artifact_effect/stun,
	/datum/artifact_effect/tesla,
	/datum/artifact_effect/teleport)

var/global/list/valid_secondary_effect_types = list(
	/datum/artifact_effect/feelings/bad,
	/datum/artifact_effect/feelings/good,
	/datum/artifact_effect/cellcharge,
	/datum/artifact_effect/celldrain,
	/datum/artifact_effect/heal,
	/datum/artifact_effect/hurt,
	/datum/artifact_effect/light,
	/datum/artifact_effect/light/darkness,
	/datum/artifact_effect/gravity,
	/datum/artifact_effect/noise,
	/datum/artifact_effect/roboheal,
	/datum/artifact_effect/robohurt)


//used in rituals to determine the value of things
var/global/list/cash_increase_list = list()

//rating of stock_parts = items with this rating
//TODO: make the function the same as in cash_increase_list
var/global/static/list/stock_parts_increase_list = list(
	/obj/item/weapon/stock_parts/capacitor = /obj/item/weapon/stock_parts/capacitor/adv,
	/obj/item/weapon/stock_parts/capacitor/adv = /obj/item/weapon/stock_parts/capacitor/adv/super,
	/obj/item/weapon/stock_parts/capacitor/adv/super = /obj/item/weapon/stock_parts/capacitor/adv/super/quadratic,
	/obj/item/weapon/stock_parts/capacitor/adv/super/quadratic = /obj/item/weapon/stock_parts/capacitor,
	/obj/item/weapon/stock_parts/scanning_module = /obj/item/weapon/stock_parts/scanning_module/adv,
	/obj/item/weapon/stock_parts/scanning_module/adv = /obj/item/weapon/stock_parts/scanning_module/adv/phasic,
	/obj/item/weapon/stock_parts/scanning_module/adv/phasic = /obj/item/weapon/stock_parts/scanning_module/adv/phasic/triphasic,
	/obj/item/weapon/stock_parts/scanning_module/adv/phasic/triphasic = /obj/item/weapon/stock_parts/scanning_module,
	/obj/item/weapon/stock_parts/manipulator = /obj/item/weapon/stock_parts/manipulator/nano,
	/obj/item/weapon/stock_parts/manipulator/nano = /obj/item/weapon/stock_parts/manipulator/nano/pico,
	/obj/item/weapon/stock_parts/manipulator/nano/pico = /obj/item/weapon/stock_parts/manipulator/nano/pico/femto,
	/obj/item/weapon/stock_parts/manipulator/nano/pico/femto = /obj/item/weapon/stock_parts/manipulator,
	/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/high,
	/obj/item/weapon/stock_parts/micro_laser/high = /obj/item/weapon/stock_parts/micro_laser/high/ultra,
	/obj/item/weapon/stock_parts/micro_laser/high/ultra = /obj/item/weapon/stock_parts/micro_laser/high/ultra/quadultra,
	/obj/item/weapon/stock_parts/micro_laser/high/ultra/quadultra = /obj/item/weapon/stock_parts/micro_laser,
	/obj/item/weapon/stock_parts/matter_bin = /obj/item/weapon/stock_parts/matter_bin/adv,
	/obj/item/weapon/stock_parts/matter_bin/adv = /obj/item/weapon/stock_parts/matter_bin/adv/super,,
	/obj/item/weapon/stock_parts/matter_bin/adv/super = /obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace,
	/obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace = /obj/item/weapon/stock_parts/matter_bin,
)

var/global/static/list/radial_question = list(
	"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_confirm"),
	"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_cancel")
)

// Alternate version of color_by_hex
// Use /hex2color(hex) for find color use this list
var/global/list/hex_by_color

// Use /hex2color(hex) for find color
// what palette are these colors from? why we need it?
var/global/static/list/color_by_hex = list(
	"black" = "#000000",
	"navy_blue" = "#000080",
	"green" = "#008000",
	"dark_gray" = "#404040",
	"maroon" = "#800000",
	"purple" = "#800080",
	"violet" = "#9933ff",
	"olive" = "#808000",
	"brown_orange" = "#824b28",
	"dark_orange" = "#b95a00",
	"sedona" = "#cc6600",
	"dark_brown" = "#917448",
	"blue" = "#0000ff",
	"deep_sky_blue" = "#00e1ff",
	"lime" = "#00ff00",
	"cyan" = "#00ffff",
	"teal" = "#33cccc",
	"red" = "#ff0000",
	"pink" = "#ff00ff",
	"orange" = "#ff9900",
	"yellow" = "#ffff00",
	"gray" = "#808080",
	"red_gray" = "#aa5f61",
	"brown" = "#b19664",
	"green_gray" = "#8daf6a",
	"blue_gray" = "#6a97b0",
	"sun" = "#ec8b2f",
	"purple_gray" = "#a2819e",
	"blue_light" = "#33ccff",
	"red_light" = "#ff3333",
	"beige" = "#ceb689",
	"pale_green_gray" = "#aed18b",
	"pale_red_gray" = "#cc9090",
	"pale_purple_gray" = "#bda2ba",
	"pale_blue_gray" = "#8bbbd5",
	"luminol" = "#66ffff",
	"silver" = "#c0c0c0",
	"off_white" = "#eeeeee",
	"white" = "#ffffff",
	"nt_red" = "#9d2300",
	"bottle_green" = "#1f6b4f",
	"pale_btl_green" = "#57967f",
	"gunmetal" = "#545c68",
	"muzzle_flash" = "#ffffb2",
	"chestnut" = "#996633",
	"beasty_brown" = "#663300",
	"wheat" = "#ffff99",
	"cyan_blue" = "#3366cc",
	"light_cyan" = "#66ccff",
	"pakistan_green" = "#006600",
	"hull" = "#436b8e",
	"amber" = "#ffbf00",
	"command_blue" = "#46698c",
	"sky_blue" = "#5ca1cc",
	"pale_orange" = "#b88a3b",
	"civie_green" = "#b7f27d",
	"titanium" = "#d1e6e3",
	"dark_gunmetal" = "#4c535b",
	"dimgray" = "#696969",
	"darkgray" = "#a9a9a9",
	"lightgray" = "#d3d3d3",
	"gainsboro" = "#dcdcdc",
	"navy" = "#000080",
	"gold" = "#ffd700",
)

// role_id = list(names)
var/global/list/deconverted_roles = list()

var/global/list/reagents_list = typecacheof(/datum/reagent)

var/global/list/virus_types_by_pool
