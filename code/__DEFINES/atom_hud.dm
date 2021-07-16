// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
/// dead, alive, sick, health status
#define HEALTH_HUD			"health"
/// a simple line rounding the mob's number health
#define STATUS_HUD			"status"
/// the job asigned to your ID
#define ID_HUD				"id"
/// wanted, released, parroled, security status
#define WANTED_HUD			"wanted"
/// loyality implant
#define IMPLOYAL_HUD		"imployal"
/// chemical implant
#define IMPCHEM_HUD			"impchem"
/// tracking implant
#define IMPTRACK_HUD		"imptrack"
/// Silicon/Mech/Circuit Status
#define DIAG_STAT_HUD		"diag_stat"
/// Silicon health bar
#define DIAG_HUD			"diag"
/// Borg/Mech/Circutry power meter
#define DIAG_BATT_HUD		"diag_batt"
/// Mech health bar
#define DIAG_MECH_HUD		"diag_mech"
/// Airlock shock overlay
#define DIAG_AIRLOCK_HUD 	"diag_airlock"
// For antag huds. these are used at the /mob level
#define ANTAG_HUD			"antag"
// Implant of mindshield
#define IMPMINDS_HUD		"impminds"
// Broken glasses hud
#define BROKEN_HUD			"broken"
// Mineral hud
#define MINE_MINERAL_HUD	"mine_mineral"
// Hud of the golem that shows its master
#define GOLEM_MASTER_HUD	"golem_master"
// Artifact huds
#define MINE_ARTIFACT_HUD	"mine_artifact"
// Holy huds
#define HOLY_HUD			"holy"
//Alien embryo hud
#define ALIEN_EMBRYO_HUD	"alien_embryo"

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
// the numbers don't mean anything, as long as they are different
#define DATA_HUD_SECURITY				1
#define DATA_HUD_MEDICAL				2
#define DATA_HUD_MEDICAL_ADV			3
#define DATA_HUD_DIAGNOSTIC				4
#define DATA_HUD_BROKEN					5
#define DATA_HUD_MINER					6
#define DATA_HUD_GOLEM					7
#define DATA_HUD_EMBRYO					8
#define DATA_HUD_HOLY					9

//antag HUD defines
#define ANTAG_HUD_CULT          10
#define ANTAG_HUD_REV           11
#define ANTAG_HUD_OPS           12
#define ANTAG_HUD_WIZ           13
#define ANTAG_HUD_SHADOW        14
#define ANTAG_HUD_TRAITOR       15
#define ANTAG_HUD_NINJA         16
#define ANTAG_HUD_CHANGELING    17
#define ANTAG_HUD_ABDUCTOR      18
#define ANTAG_HUD_ALIEN         19
#define ANTAG_HUD_DEATHCOM      20
#define ANTAG_HUD_ERT           21
#define ANTAG_HUD_MALF          22
#define ANTAG_HUD_ZOMB          23
#define ANTAG_HUD_GANGSTER      24
#define ANTAG_HUD_SPACECOP      25

/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20
