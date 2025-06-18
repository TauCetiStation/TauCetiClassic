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
#define EVIL_SHADE             "Evil Shade"
#define ROLE_SHADOWLING        "Shadowling"
#define ROLE_ABDUCTOR          "Abductor"
#define ROLE_FAMILIES          "Families"
#define ROLE_GHOSTLY           "Ghostly Roles"
#define ROLE_REPLICATOR        "Replicator"
#define ROLE_WILD_ANIMAL       "Animal"


#define ROLE_ERT               "Emergency Response Team"
#define ROLE_DRONE             "Maintenance Drone"

//Prefs for ignore a question which give special_roles
#define IGNORE_PAI          "Pai"
#define IGNORE_TSTAFF       "Religion staff"
#define IGNORE_SURVIVOR     "Survivor"
#define IGNORE_POSBRAIN     "Positronic brain"
#define IGNORE_DRONE        "Drone"
#define IGNORE_NARSIE_SLAVE "Nar-sie slave"
#define IGNORE_SYNDI_BORG   "Syndicate robot"
#define IGNORE_LARVA        "Larva"
#define IGNORE_EVENT_BLOB   "Event blob"
#define IGNORE_EMINENCE     "Eminence"

var/global/list/special_roles_ignore_question = list(
	ROLE_TRAITOR    = null,
	ROLE_OPERATIVE  = list(IGNORE_SYNDI_BORG),
	ROLE_CHANGELING = null,
	ROLE_WIZARD     = null,
	ROLE_MALF       = null,
	ROLE_REV        = null,
	ROLE_ALIEN      = list(IGNORE_LARVA),
	ROLE_CULTIST    = list(IGNORE_NARSIE_SLAVE, IGNORE_EMINENCE),
	ROLE_BLOB       = list(IGNORE_EVENT_BLOB),
	ROLE_SHADOWLING = null,
	ROLE_FAMILIES   = null,
	ROLE_REPLICATOR = null,
	ROLE_GHOSTLY    = list(IGNORE_PAI, IGNORE_TSTAFF, IGNORE_SURVIVOR, IGNORE_POSBRAIN, IGNORE_DRONE),
)

var/global/list/special_roles
var/global/list/antag_roles
var/global/list/full_ignore_question
