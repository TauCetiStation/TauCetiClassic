proc/ShowFirstParamsFromAssocList(assoc_list)
	var/FirstParams = list()
	for (var/param in assoc_list)
		FirstParams += param
	return FirstParams

proc/ShowSecondParamsFromAssocList(assoc_list)
	var/SecondParams = list()
	for (var/FirstParam in assoc_list)
		for (var/SecondParam in assoc_list[FirstParam])
			SecondParams += SecondParam
	return SecondParams

//Values for antag preferences, event roles, etc. unified here

//Any number of preferences could be.
//These are synced with the Database, if you change the values of the defines
//then you MUST update the database! Jobbans also uses those defines!!
#define ROLE_TRAITOR           "Traitor"
#define ROLE_OPERATIVE         "Operative"
#define ROLE_CHANGELING        "Changeling"
#define ROLE_WIZARD            "Wizard"
#define ROLE_MALF              "Malf AI"
#define ROLE_REV               "Revolutionary"
#define ROLE_ALIEN             "Xenomorph"
#define ROLE_CULTIST           "Cultist"
#define ROLE_BLOB              "Blob"
#define ROLE_NINJA             "Ninja"
#define ROLE_RAIDER            "Raider"
#define ROLE_SHADOWLING        "Shadowling"
#define ROLE_ABDUCTOR          "Abductor"
#define ROLE_FAMILIES          "Families"
#define ROLE_GHOSTLY           "Ghostly Roles"

#define ROLE_ERT               "Emergency Response Team"
#define ROLE_DRONE             "Maintenance Drone"

//Prefs for ignore a question which give special_roles
#define IGNORE_PLANT        "Diona"
#define IGNORE_PAI          "Pai"
#define IGNORE_TSTAFF       "Religion staff"
#define IGNORE_SURVIVOR     "Survivor"
#define IGNORE_POSBRAIN     "Positronic brain"
#define IGNORE_DRONE        "Drone"
#define IGNORE_BORER        "Borer"
#define IGNORE_FAMILIAR     "Religion familiar"
#define IGNORE_NARSIE_SLAVE "Nar-sie slave"
#define IGNORE_COPS         "Cops"
#define IGNORE_DEALER       "Smuggler"
#define IGNORE_SYNDI_BORG   "Syndicate robot"
#define IGNORE_FACEHUGGER   "Facehugger"
#define IGNORE_LAVRA        "Lavra"
#define IGNORE_EVENT_BLOB   "Event blob"

var/global/list/special_roles_ignore_question = list(
	ROLE_TRAITOR    = null,
	ROLE_OPERATIVE  = list(IGNORE_SYNDI_BORG),
	ROLE_CHANGELING = null,
	ROLE_WIZARD     = null,
	ROLE_MALF       = null,
	ROLE_REV        = null,
	ROLE_ALIEN      = list(IGNORE_FACEHUGGER, IGNORE_LAVRA),
	ROLE_CULTIST    = list(IGNORE_NARSIE_SLAVE),
	ROLE_BLOB       = list(IGNORE_EVENT_BLOB),
	ROLE_NINJA      = null,
	ROLE_RAIDER     = null,
	ROLE_SHADOWLING = null,
	ROLE_ABDUCTOR   = null,
	ROLE_FAMILIES   = list(IGNORE_COPS, IGNORE_DEALER),
	ROLE_GHOSTLY    = list(IGNORE_PLANT, IGNORE_PAI, IGNORE_TSTAFF, IGNORE_SURVIVOR, IGNORE_POSBRAIN, IGNORE_DRONE ,IGNORE_FAMILIAR, IGNORE_BORER),
)

var/global/list/special_roles = ShowFirstParamsFromAssocList(special_roles_ignore_question)
var/global/list/antag_roles = global.special_roles - ROLE_GHOSTLY
var/global/list/full_ignore_question = ShowSecondParamsFromAssocList(special_roles_ignore_question)
