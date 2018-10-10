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

#define ROLE_ERT               "Emergency Response Team"
#define ROLE_DRONE             "Maintenance Drone"


//Equating to one means that it's not gamemode prefs, so it should be visible always.
//Pay attention to 'IS_MODE_COMPILED' parametr.
//If there will be link to non-existent mode or any typo mistake, mode wouldn't be visible in prefs.
var/global/list/special_roles = list(
	ROLE_TRAITOR = IS_MODE_COMPILED("traitor"),          //0
	ROLE_OPERATIVE = IS_MODE_COMPILED("nuclear"),        //1
	ROLE_CHANGELING = IS_MODE_COMPILED("changeling"),    //2
	ROLE_WIZARD = IS_MODE_COMPILED("wizard"),            //3
	ROLE_MALF = IS_MODE_COMPILED("malfunction"),         //4
	ROLE_REV = IS_MODE_COMPILED("revolution"),           //5
	ROLE_ALIEN = 1,                                      //6
	ROLE_PAI = 1,                                        //7
	ROLE_CULTIST = IS_MODE_COMPILED("cult"),             //8
	ROLE_BLOB =  IS_MODE_COMPILED("blob"),               //9
	ROLE_NINJA = 1,                                      //10
	ROLE_RAIDER = IS_MODE_COMPILED("heist"),             //11
	ROLE_PLANT = 1,                                      //12
	ROLE_MEME = IS_MODE_COMPILED("meme"),                //13
	ROLE_MUTINEER = IS_MODE_COMPILED("mutiny"),          //14
	ROLE_SHADOWLING = IS_MODE_COMPILED("shadowling"),    //15
	ROLE_ABDUCTOR = IS_MODE_COMPILED("abduction")        //16
)
