// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
/// dead, alive, sick, health status
#define HEALTH_HUD			"1"
/// a simple line rounding the mob's number health
#define STATUS_HUD			"2"
/// the job asigned to your ID
#define ID_HUD				"3"
/// wanted, released, parroled, security status
#define WANTED_HUD			"4"
/// loyality implant
#define IMPLOYAL_HUD		"5"
/// chemical implant
#define IMPCHEM_HUD			"6"
/// tracking implant
#define IMPTRACK_HUD		"7"
/// Silicon/Mech/Circuit Status
#define DIAG_STAT_HUD		"8"
/// Silicon health bar
#define DIAG_HUD			"9"
/// Borg/Mech/Circutry power meter
#define DIAG_BATT_HUD		"10"
/// Mech health bar
#define DIAG_MECH_HUD		"11"
/// Airlock shock overlay
#define DIAG_AIRLOCK_HUD 	"12"
// For antag huds. these are used at the /mob level
#define ANTAG_HUD			"13"
// Implant of mindshield
#define IMPMINDS_HUD		"14"
// Broken glasses hud
#define BROKEN_HUD			"15"
// Mineral hud
#define MINE_MINERAL_HUD	"16"
// Hud of the golem that shows its master
#define GOLEM_MASTER_HUD	"17"
// Artifact huds
#define MINE_ARTIFACT_HUD	"18"
//Alien embryo hud
#define ALIEN_EMBRYO_HUD	"19"

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

//antag HUD defines
#define ANTAG_HUD_CULT          9
#define ANTAG_HUD_REV           10
#define ANTAG_HUD_OPS           11
#define ANTAG_HUD_WIZ           12
#define ANTAG_HUD_SHADOW        13
#define ANTAG_HUD_TRAITOR       14
#define ANTAG_HUD_NINJA         15
#define ANTAG_HUD_CHANGELING    16
#define ANTAG_HUD_ABDUCTOR      17
#define ANTAG_HUD_ALIEN         18
#define ANTAG_HUD_DEATHCOM      19
#define ANTAG_HUD_ERT           20
#define ANTAG_HUD_MALF          21
#define ANTAG_HUD_ZOMB          22

/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20
