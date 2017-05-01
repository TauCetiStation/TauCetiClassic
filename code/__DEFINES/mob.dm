///////////////////ORGAN STATUS DEFINES///////////////////
#define ORGAN_CUT_AWAY   1
#define ORGAN_ATTACHABLE 2
#define ORGAN_BLEEDING   4
#define ORGAN_BROKEN     8
#define ORGAN_ROBOT      16
#define ORGAN_SPLINTED   32
#define ORGAN_DEAD       64
#define ORGAN_MUTATED    128
#define ORGAN_ARTERY_CUT 256
#define ORGAN_TENDON_CUT 512

// BODYPART/ORGAN DEFINES
// Limbs.
#define BP_CHEST "chest"
#define BP_GROIN "groin"
#define BP_HEAD  "head"
#define BP_L_ARM "l_arm"
#define BP_R_ARM "r_arm"
#define BP_L_LEG "l_leg"
#define BP_R_LEG "r_leg"

// Organs.
#define BP_MOUTH   "mouth"
#define BP_EYES    "eyes"
#define BP_HEART   "heart"
#define BP_LUNGS   "lungs"
#define BP_BRAIN   "brain"
#define BP_LIVER   "liver"
#define BP_KIDNEYS "kidneys"
//Xenos
#define BP_EGG      "egg sac"
#define BP_PLASMA   "plasma vessel"
#define BP_NEURO    "neurotoxin gland"
#define BP_ACID     "acid gland"
#define BP_HIVE     "hive node"
#define BP_RESIN    "resin spinner"

// Defines mob sizes, used by lockers and to determine what is considered a small sized mob, etc.
#define MOB_LARGE  		40
#define MOB_MEDIUM 		20
#define MOB_SMALL 		10
#define MOB_TINY 		5
#define MOB_MINISCULE	1

// Incapacitation flags, used by the mob/proc/incapacitated() proc
#define INCAPACITATION_NONE 0
#define INCAPACITATION_RESTRAINED 1
#define INCAPACITATION_BUCKLED_PARTIALLY 2
#define INCAPACITATION_BUCKLED_FULLY 4
#define INCAPACITATION_STUNNED 8
#define INCAPACITATION_FORCELYING 16 //needs a better name - represents being knocked down BUT still conscious.
#define INCAPACITATION_KNOCKOUT 32

#define INCAPACITATION_KNOCKDOWN (INCAPACITATION_KNOCKOUT|INCAPACITATION_FORCELYING)
#define INCAPACITATION_DISABLED (INCAPACITATION_KNOCKDOWN|INCAPACITATION_STUNNED)
#define INCAPACITATION_DEFAULT (INCAPACITATION_RESTRAINED|INCAPACITATION_BUCKLED_FULLY|INCAPACITATION_DISABLED)
#define INCAPACITATION_ALL (~INCAPACITATION_NONE)

// These control the amount of blood lost from burns. The loss is calculated so
// that dealing just enough burn damage to kill the player will cause the given
// proportion of their max blood volume to be lost
// (e.g. 0.6 == 60% lost if 200 burn damage is taken).
#define FLUIDLOSS_WIDE_BURN 0.6 //for burns from heat applied over a wider area, like from fire
#define FLUIDLOSS_CONC_BURN 0.4 //for concentrated burns, like from lasers

#define AGE_MIN 25			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be

#define LEFT  1
#define RIGHT 2

//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock

// intent flags
#define I_HELP		"help"
#define I_DISARM	"disarm"
#define I_GRAB		"grab"
#define I_HURT		"hurt" // or harm? or hurt? or what?

//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

// Species Names
#define S_HUMAN         "Human"
#define S_UNATHI        "Unathi"
#define S_TAJARAN       "Tajaran"
#define S_SKRELL        "Skrell"
#define S_VOX           "Vox"
#define S_VOX_ARMALIS   "Vox Armalis"
#define S_DIONA         "Diona"
#define S_IPC           "Machine"
#define S_ABDUCTOR      "Abductor"
#define S_SKELETON      "Skeleton"
#define S_SHADOWLING    "Shadowling"
#define S_MONKEY        "Monkey"
#define S_MONKEY_U      "Stok"
#define S_MONKEY_T      "Farwa"
#define S_MONKEY_S      "Neaera"
#define S_MONKEY_D      "Diona Nymph"
#define S_SLIME         "Slime"
#define S_PROMETHEAN    "Promethean"
#define S_XENO_FACE     "Alien Facehugger"
#define S_XENO_LARVA    "Alien Larva"
#define S_XENO_DRONE    "Xenomorph Drone"
#define S_XENO_HUNTER   "Xenomorph Hunter"
#define S_XENO_SENTINEL "Xenomorph Sentinel"
#define S_XENO_QUEEN    "Xenomorph Queen"
#define S_DOG           "Dog"

//Some on_mob_life() procs check for alien races.
#define IS_DIONA  1
#define IS_VOX	  2
#define IS_SKRELL 3
#define IS_UNATHI 4

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.

#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up

//Nutrition levels for humans.
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150

// Factor of how fast mob nutrition decreases
#define HUNGER_FACTOR 0.05

// How many units of reagent are consumed per tick, by default.
#define REAGENTS_METABOLISM 0.2

// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4

//Ian can lick or sniff
#define IAN_STANDARD 0
#define IAN_LICK     1
#define IAN_SNIFF    2
