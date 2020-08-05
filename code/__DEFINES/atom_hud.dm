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
/// Gland indicators for abductors
#define GLAND_HUD 			"13"
//for antag huds. these are used at the /mob level
#define ANTAG_HUD			"14"

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY				1
#define DATA_HUD_MEDICAL				3
#define DATA_HUD_DIAGNOSTIC				4
#define DATA_HUD_ABDUCTOR				5

//antag HUD defines
#define ANTAG_HUD_CULT          6
#define ANTAG_HUD_REV           7
#define ANTAG_HUD_OPS           8
#define ANTAG_HUD_WIZ           9
#define ANTAG_HUD_SHADOW        10
#define ANTAG_HUD_TRAITOR       11
#define ANTAG_HUD_NINJA         12
#define ANTAG_HUD_CHANGELING    13
#define ANTAG_HUD_ABDUCTOR      14
#define ANTAG_HUD_GANGSTER      15

/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20
