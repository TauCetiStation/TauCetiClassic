// Dynamic Mode
#define CURRENT_LIVING_PLAYERS	"living"
#define CURRENT_LIVING_ANTAGS	"antags"
#define CURRENT_DEAD_PLAYERS	"dead"
#define CURRENT_OBSERVERS	"observers"

// Faction IDs
#define ABDUCTORS "abductor team"
#define BLOODCULT "cult of Nar-Sie"
#define REVOLUTION "revolution"
//#define ERT "emergency response team"
#define DEATHSQUAD "Nanotrasen deathsquad"
#define SYNDIOPS "syndicate operatives"
#define SYNDIESQUAD "syndicate elite strike team"
#define CUSTOMSQUAD "custom squad"
#define HEIST "vox Shoal"
#define BLOBCONGLOMERATE "blob conglomerate"
#define SPIDERCLAN "spider clan"
#define XENOMORPH_HIVE "alien hivemind"
//-------
#define HIVEMIND "changeling hivemind"
#define WIZFEDERATION "wizard federation"
// Role IDs
#define ABDUCTOR_AGENT "abductor_agent"
#define ABDUCTOR_SCI "abductor_sci"
#define ABDUCTED "abducted"
#define TRAITOR "traitor"
#define CHANGELING "changeling"
#define THRALL "thrall"
#define WIZARD "wizard"
#define CULTIST "cultist"
#define NUKE_OP "nuclear operative"
#define NUKE_OP_LEADER "nuclear operative leader"
#define HEADREV "head revolutionary"
#define REV "revolutionary"
#define NINJA "Space Ninja"
#define DEATHSQUADIE "death commando"
#define SYNDIESQUADIE "syndicate commando"
#define MALF "malfunctioning AI"
#define MALFBOT "malfunctioning-slaved cyborg"
#define VOXRAIDER "vox raider"
#define BLOBOVERMIND "blob overmind"
#define BLOBCEREBRATE "blob cerebrate"
#define XENOMORPH "alien"
#define PRISONER "prisoner"

#define GREET_DEFAULT		"default"
#define GREET_ROUNDSTART	"roundstart"
#define GREET_LATEJOIN		"latejoin"
#define GREET_ADMINTOGGLE	"admintoggle"
#define GREET_CUSTOM		"custom"
#define GREET_MIDROUND		"midround"
#define GREET_MASTER		"master"

#define GREET_AUTOTATOR		"autotator"
#define GREET_SYNDBEACON	"syndbeacon"

#define GREET_CONVERTED		"converted"
#define GREET_PAMPHLET		"pamphlet"
#define GREET_SOULSTONE		"soulstone"
#define GREET_SOULBLADE		"soulblade"
#define GREET_RESURRECT		"resurrect"
#define GREET_SACRIFICE		"sacrifice"

#define GREET_REVSQUAD_CONVERTED "revsquad"
#define GREET_PROVOC_CONVERTED	 "provocateur"

///////////////// ROLE TYPE DEFINES ///////////////////

///////////////// FACTION STAGES //////////////////////
#define FACTION_DEFEATED	-1
#define FACTION_DORMANT		0
#define FACTION_ACTIVE		1
#define FACTION_ENDGAME		3
#define FACTION_VICTORY		5

#define MALF_CHOOSING_NUKE	4

////////////////////////////////////////////////////////////////////////////////

// -- Objectives flags

#define FACTION_OBJECTIVE 1

#define FROM_GHOSTS 1
#define FROM_PLAYERS 2

// -- Revs

#define ADD_REVOLUTIONARY_FAIL_IS_COMMAND -1
#define ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED -2
#define ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED -3
#define ADD_REVOLUTIONARY_FAIL_IS_REV -4

// -- Protected roles

#define PROB_PROTECTED_REGULAR 50
#define PROB_PROTECTED_RARE    80

#define FACTION_FAILURE -1

// -- The paper

#define INTERCEPT_TIME_LOW 10 MINUTES
#define INTERCEPT_TIME_HIGH 18 MINUTES

// -- Injection delays (in ticks, ie, you need the /20 to get the real result)

#define LATEJOIN_DELAY_MIN (5 MINUTES)/20
#define LATEJOIN_DELAY_MAX (30 MINUTES)/20

#define MIDROUND_DELAY_MIN (15 MINUTES)/20
#define MIDROUND_DELAY_MAX (50 MINUTES)/20

// -- Rulesets flags

#define HIGHLANDER_RULESET 1
#define TRAITOR_RULESET 2
#define MINOR_RULESET 4

// -- Distribution "modes"

#define LORENTZ "Lorentz distribution"
#define GAUSS "Normal distribution"
#define DIRAC "Rigged threat number"
#define EXPONENTIAL "Peaceful bias"
#define UNIFORM "Uniform distribution"
