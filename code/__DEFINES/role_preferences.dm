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

var/global/list/antag_roles = list(
	ROLE_TRAITOR,
	ROLE_OPERATIVE,
	ROLE_CHANGELING,
	ROLE_WIZARD,
	ROLE_MALF,
	ROLE_REV,
	ROLE_ALIEN,
	ROLE_CULTIST,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_RAIDER,
	ROLE_SHADOWLING,
	ROLE_ABDUCTOR,
	ROLE_FAMILIES,
)

var/global/list/special_roles = list(
	ROLE_TRAITOR,
	ROLE_OPERATIVE,
	ROLE_CHANGELING,
	ROLE_WIZARD,
	ROLE_MALF,
	ROLE_REV,
	ROLE_ALIEN,
	ROLE_CULTIST,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_RAIDER,
	ROLE_SHADOWLING,
	ROLE_ABDUCTOR,
	ROLE_FAMILIES,
	ROLE_GHOSTLY,
)

//Prefs for ignore a question which give ghosty roles
#define IGNORE_PLANT        "Diona"
#define IGNORE_PAI          "Pai"
#define IGNORE_TSTAFF       "Chaplain staff"
#define IGNORE_SURVIVOR     "Survivor"
#define IGNORE_POSBRAIN     "Positronic brain"
#define IGNORE_DRONE        "Drone"
#define IGNORE_BORER        "Borer"
#define IGNORE_FAMILIAR     "Chaplain familiar"
#define IGNORE_NARSIE_SLAVE "Nar-sie slave"

var/global/list/full_ignore_question = list(
	IGNORE_PAI,
	IGNORE_BORER,
	IGNORE_DRONE,
	IGNORE_PLANT,
	IGNORE_TSTAFF,
	IGNORE_FAMILIAR,
	IGNORE_POSBRAIN,
	IGNORE_SURVIVOR,
	IGNORE_NARSIE_SLAVE,
)
