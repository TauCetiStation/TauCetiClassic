//Values for antag preferences, event roles, etc. unified here

//Any number of preferences could be.
//These are synced with the Database, if you change the values of the defines
//then you MUST update the database! Jobbans also uses those defines!!
#define ROLE_PAI               "pAI"
#define ROLE_PLANT             "Diona"
#define ROLE_SHADOWLING        "Shadowling"
#define ROLE_ABDUCTOR          "Abductor"
#define ROLE_GHOSTLY           "Ghostly Roles"

#define ROLE_ERT               "Emergency Response Team"
#define ROLE_DRONE             "Maintenance Drone"

var/global/list/antag_roles = list(
	TRAITOR,
	NUKE_OP,
	CHANGELING,
	WIZARD,
	MALF,
	REV,
	XENOMORPH,
	CULTIST,
	BLOBOVERMIND,
	NINJA,
	VOXRAIDER,
	ROLE_SHADOWLING,
	ROLE_ABDUCTOR,
)

var/global/list/special_roles = list(
	TRAITOR,
	NUKE_OP,
	CHANGELING,
	WIZARD,
	MALF,
	REV,
	XENOMORPH,
	CULTIST,
	BLOBOVERMIND ,
	NINJA,
	VOXRAIDER,
	ROLE_SHADOWLING,
	ROLE_ABDUCTOR,
	ROLE_GHOSTLY,
)

//Prefs for ignore a question which give ghosty roles
#define IGNORE_PLANT       "diona"
#define IGNORE_PAI         "pai"
#define IGNORE_TSTAFF      "chstaff"
#define IGNORE_SURVIVOR    "survivor"
#define IGNORE_POSBRAIN    "posibrain"
#define IGNORE_DRONE       "drone"
#define IGNORE_BORER       "borer"
#define IGNORE_FAMILIAR    "chfamiliar"
