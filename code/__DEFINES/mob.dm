///////////////////ORGAN DEFINES///////////////////
#define ORGAN_CUT_AWAY		1
#define ORGAN_GAUZED 		2
#define ORGAN_ATTACHABLE 	4
#define ORGAN_BLEEDING 		8
#define ORGAN_BROKEN 		32
#define ORGAN_DESTROYED 	64
#define ORGAN_ROBOT 		128
#define ORGAN_SPLINTED 		256
#define SALVED 				512
#define ORGAN_DEAD 			1024
#define ORGAN_MUTATED 		2048

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

//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

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
