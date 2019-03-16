var/global/list/scarySounds = list(
	'sound/weapons/thudswoosh.ogg',
    'sound/weapons/Taser.ogg', 'sound/weapons/armbomb.ogg',
    'sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg',
    'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg',
    'sound/voice/hiss5.ogg', 'sound/voice/hiss6.ogg',
    'sound/effects/Glassbr1.ogg', 'sound/effects/Glassbr2.ogg',
    'sound/effects/Glassbr3.ogg', 'sound/items/Welder.ogg',
    'sound/items/Welder2.ogg','sound/machines/airlock/airlockToggle.ogg',
    'sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'
	)

//added for Xenoarchaeology, might be useful for other stuff
var/global/list/alphabet_uppercase = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")

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
	ROLE_PLANT = 0,
	ROLE_TRAITOR = 480,
	ROLE_OPERATIVE = 480,
	ROLE_CHANGELING = 480,
	ROLE_RAIDER = 480,
	ROLE_ALIEN = 480,
	ROLE_WIZARD = 960,
	ROLE_ERT = 960,
	ROLE_REV = 960,
	ROLE_MEME = 960,
	ROLE_DRONE = 960,
	ROLE_CULTIST = 960,
	ROLE_BLOB = 960,
	ROLE_NINJA = 1200,
	ROLE_MALF = 1200,
	ROLE_MUTINEER = 1200,
	ROLE_SHADOWLING = 1200,
	ROLE_ABDUCTOR = 1200
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
