//added for Xenoarchaeology, might be useful for other stuff
var/global/list/alphabet_uppercase = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")

var/global/list/hex_characters = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")

var/list/RESTRICTED_CAMERA_NETWORKS = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"thunder",
	"ERT",
	"NUKE",
	"AURORA"
	)

// Posters
//var/global/list/datum/poster/poster_designs = typesof(/datum/poster) - /datum/poster

var/list/roles_ingame_minute_unlock = list(
	ROLE_PAI = 0,
	ROLE_PLANT = 40000,
	ROLE_TRAITOR = 720,
	ROLE_OPERATIVE = 2160,
	ROLE_CHANGELING = 2160,
	ROLE_RAIDER = 4320,
	ROLE_ALIEN = 1440,
	ROLE_WIZARD = 2880,
	ROLE_ERT = 1440,
	ROLE_REV = 1440,
	ROLE_MEME = 4320,
	ROLE_DRONE = 1440,
	ROLE_CULTIST = 3600,
	ROLE_BLOB = 2880,
	ROLE_NINJA = 4320,
	ROLE_MALF = 3600,
	ROLE_MUTINEER = 1440,
	ROLE_SHADOWLING = 4320,
	ROLE_ABDUCTOR = 2880,
	ROLE_GHOSTLY = 360,
)

var/global/list/datum_alarm_list = list()

var/global/list/all_artifact_effect_types = list(
	/datum/artifact_effect/cold,
	/datum/artifact_effect/badfeeling,
	/datum/artifact_effect/cellcharge,
	/datum/artifact_effect/celldrain,
	/datum/artifact_effect/dnaswitch,
	/datum/artifact_effect/emp,
	/datum/artifact_effect/gasco2,
	/datum/artifact_effect/forcefield,
	/datum/artifact_effect/gasnitro,
	/datum/artifact_effect/gasoxy,
	/datum/artifact_effect/gasphoron,
	/datum/artifact_effect/gassleeping,
	/datum/artifact_effect/goodfeeling,
	/datum/artifact_effect/heal,
	/datum/artifact_effect/heat,
	/datum/artifact_effect/hurt,
	/datum/artifact_effect/radiate,
	/datum/artifact_effect/roboheal,
	/datum/artifact_effect/robohurt,
	/datum/artifact_effect/sleepy,
	/datum/artifact_effect/stun,
	/datum/artifact_effect/tesla,
	/datum/artifact_effect/teleport)

var/global/list/valid_primary_effect_types = list(
	/datum/artifact_effect/cold,
	/datum/artifact_effect/cellcharge,
	/datum/artifact_effect/celldrain,
	/datum/artifact_effect/dnaswitch,
	/datum/artifact_effect/emp,
	/datum/artifact_effect/gasco2,
	/datum/artifact_effect/forcefield,
	/datum/artifact_effect/gasnitro,
	/datum/artifact_effect/gasoxy,
	/datum/artifact_effect/gasphoron,
	/datum/artifact_effect/gassleeping,
	/datum/artifact_effect/heal,
	/datum/artifact_effect/heat,
	/datum/artifact_effect/hurt,
	/datum/artifact_effect/radiate,
	/datum/artifact_effect/sleepy,
	/datum/artifact_effect/stun,
	/datum/artifact_effect/tesla,
	/datum/artifact_effect/teleport)

var/global/list/valid_secondary_effect_types = list(
	/datum/artifact_effect/cold,
	/datum/artifact_effect/badfeeling,
	/datum/artifact_effect/cellcharge,
	/datum/artifact_effect/celldrain,
	/datum/artifact_effect/gasco2,
	/datum/artifact_effect/gasnitro,
	/datum/artifact_effect/gasoxy,
	/datum/artifact_effect/gasphoron,
	/datum/artifact_effect/gassleeping,
	/datum/artifact_effect/goodfeeling,
	/datum/artifact_effect/heal,
	/datum/artifact_effect/heat,
	/datum/artifact_effect/hurt,
	/datum/artifact_effect/radiate)


//used in rituals to determine the value of things
var/global/list/cash_increase_list = list()

//rating of stock_parts = items with this rating
//TODO: make the function the same as in cash_increase_list
var/global/static/list/stock_parts_increase_list = list(
	/obj/item/weapon/stock_parts/capacitor = /obj/item/weapon/stock_parts/capacitor/adv,
	/obj/item/weapon/stock_parts/capacitor/adv = /obj/item/weapon/stock_parts/capacitor/super,
	/obj/item/weapon/stock_parts/capacitor/super = /obj/item/weapon/stock_parts/capacitor/quadratic,
	/obj/item/weapon/stock_parts/capacitor/quadratic = /obj/item/weapon/stock_parts/capacitor,
	/obj/item/weapon/stock_parts/scanning_module = /obj/item/weapon/stock_parts/scanning_module/adv,
	/obj/item/weapon/stock_parts/scanning_module/adv = /obj/item/weapon/stock_parts/scanning_module/phasic,
	/obj/item/weapon/stock_parts/scanning_module/phasic = /obj/item/weapon/stock_parts/scanning_module/triphasic,
	/obj/item/weapon/stock_parts/scanning_module/triphasic = /obj/item/weapon/stock_parts/scanning_module,
	/obj/item/weapon/stock_parts/manipulator = /obj/item/weapon/stock_parts/manipulator/nano,
	/obj/item/weapon/stock_parts/manipulator/nano = /obj/item/weapon/stock_parts/manipulator/pico,
	/obj/item/weapon/stock_parts/manipulator/pico = /obj/item/weapon/stock_parts/manipulator/femto,
	/obj/item/weapon/stock_parts/manipulator/femto = /obj/item/weapon/stock_parts/manipulator,
	/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/high,
	/obj/item/weapon/stock_parts/micro_laser/high = /obj/item/weapon/stock_parts/micro_laser/ultra,
	/obj/item/weapon/stock_parts/micro_laser/ultra = /obj/item/weapon/stock_parts/micro_laser/quadultra,
	/obj/item/weapon/stock_parts/micro_laser/quadultra = /obj/item/weapon/stock_parts/micro_laser,
	/obj/item/weapon/stock_parts/matter_bin = /obj/item/weapon/stock_parts/matter_bin/adv,
	/obj/item/weapon/stock_parts/matter_bin/adv = /obj/item/weapon/stock_parts/matter_bin/super,,
	/obj/item/weapon/stock_parts/matter_bin/super = /obj/item/weapon/stock_parts/matter_bin/bluespace,
	/obj/item/weapon/stock_parts/matter_bin/bluespace = /obj/item/weapon/stock_parts/matter_bin,
)

var/global/static/list/radial_question = list(
	"Yes" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_confirm"),
	"No" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_cancel")
)
