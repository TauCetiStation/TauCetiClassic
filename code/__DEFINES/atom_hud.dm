// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
/// dead, alive, sick, health status
#define HEALTH_HUD			"health"
/// a simple line rounding the mob's number health
#define STATUS_HUD			"status"
/// None, Standard, Premium, insurance type
#define INSURANCE_HUD       "insurance"
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
// Obedience implant
#define IMPOBED_HUD			"impobed"
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
#define DATA_HUD_SECURITY       "data_hud_sec"
#define DATA_HUD_MEDICAL        "data_hud_med"
#define DATA_HUD_MEDICAL_ADV    "data_hud_med_adv"
#define DATA_HUD_DIAGNOSTIC     "data_hud_diag"
#define DATA_HUD_BROKEN         "data_hud_broken"
#define DATA_HUD_MINER          "data_hud_miner"
#define DATA_HUD_GOLEM          "data_hud_golem"
#define DATA_HUD_EMBRYO         "data_hud_embryo"
#define DATA_HUD_HOLY           "data_hud_holy"

//antag HUD defines
#define ANTAG_HUD_CULT          "antag_hud_cult"
#define ANTAG_HUD_REV           "antag_hud_rev"
#define ANTAG_HUD_OPS           "antag_hud_ops"
#define ANTAG_HUD_WIZ           "antag_hud_wiz"
#define ANTAG_HUD_SHADOW        "antag_hud_shadow"
#define ANTAG_HUD_TRAITOR       "antag_hud_traitor"
#define ANTAG_HUD_NINJA         "antag_hud_ninja"
#define ANTAG_HUD_CHANGELING    "antag_hud_chang"
#define ANTAG_HUD_ABDUCTOR      "antag_hud_abductor"
#define ANTAG_HUD_ALIEN         "antag_hud_alien"
#define ANTAG_HUD_DEATHCOM      "antag_hud_deathcom"
#define ANTAG_HUD_ERT           "antag_hud_ert"
#define ANTAG_HUD_MALF          "antag_hud_malf"
#define ANTAG_HUD_ZOMB          "antag_hud_zomb"
#define ANTAG_HUD_GANGSTER      "antag_hud_gangster"
#define ANTAG_HUD_SPACECOP      "antag_hud_cop"
#define ANTAG_HUD_REPLICATOR    "antag_hud_replicator"
#define ANTAG_HUD_PIRATES       "antag_hud_pirates"
#define ANTAG_HUD_TEAMS_RED     "antag_hud_teams_red"
#define ANTAG_HUD_TEAMS_BLUE    "antag_hud_teams_blue"


/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20
