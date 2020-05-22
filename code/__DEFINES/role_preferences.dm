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
#define ROLE_PAI               "pAI"
#define ROLE_CULTIST           "Cultist"
#define ROLE_BLOB              "Blob"
#define ROLE_NINJA             "Ninja"
#define ROLE_RAIDER            "Raider"
#define ROLE_PLANT             "Diona"
#define ROLE_MEME              "Meme"
#define ROLE_MUTINEER          "Mutineer"
#define ROLE_SHADOWLING        "Shadowling"
#define ROLE_ABDUCTOR          "Abductor"
#define ROLE_GHOSTLY           "Ghostly Roles"

#define ROLE_ERT               "Emergency Response Team"
#define ROLE_DRONE             "Maintenance Drone"


var/global/list/special_roles = list(
	ROLE_TRAITOR,
	ROLE_OPERATIVE,
	ROLE_CHANGELING,
	ROLE_WIZARD,
	ROLE_MALF,
	ROLE_REV,
	ROLE_ALIEN,
	ROLE_CULTIST,
	ROLE_BLOB ,
	ROLE_NINJA,
	ROLE_RAIDER,
	ROLE_MEME,
	ROLE_MUTINEER,
	ROLE_SHADOWLING,
	ROLE_ABDUCTOR,
	ROLE_GHOSTLY,
)

//Prefs for ignore a question which give ghosty roles
#define IGNORE_PLANT       "diona"
#define IGNORE_TSTAFF      "chstaff"
#define IGNORE_SURVIVOR    "survivor"
#define IGNORE_POSBRAIN    "posibrain"
#define IGNORE_DRONE       "drone"
#define IGNORE_BORER       "borer"
#define IGNORE_FAMILIAR    "chfamiliar"
