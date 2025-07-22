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
