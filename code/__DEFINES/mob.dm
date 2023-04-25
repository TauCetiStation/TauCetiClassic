///////////////////ORGAN STATUS DEFINES///////////////////
#define ORGAN_CUT_AWAY   1
#define ORGAN_ATTACHABLE 2
#define ORGAN_BLEEDING   4
#define ORGAN_BROKEN     8
#define ORGAN_SPLINTED   16
#define ORGAN_DEAD       32
#define ORGAN_MUTATED    64
#define ORGAN_ARTERY_CUT 128

#define DROPLIMB_EDGE  0
#define DROPLIMB_BLUNT 1
#define DROPLIMB_BURN  2

#define DROPLIMB_THRESHOLD_EDGE    5
#define DROPLIMB_THRESHOLD_TEAROFF 2
#define DROPLIMB_THRESHOLD_DESTROY 1
#define ORGAN_DAMAGE_SPILLOVER_MULTIPLIER 0.005

#define BODYPART_ORGANIC   1
#define BODYPART_ROBOTIC   2
#define BODYPART_SKELETON  3

// Bodypart defines
#define BP_CHEST  "chest"
#define BP_GROIN  "groin"
#define BP_HEAD   "head"
#define BP_L_ARM  "l_arm"
#define BP_R_ARM  "r_arm"
#define BP_L_LEG  "l_leg"
#define BP_R_LEG  "r_leg"
#define BP_ACTIVE_ARM "active_arm"
#define BP_INACTIVE_ARM "inactive_arm"

// Organ defines.
#define O_MOUTH    "mouth"
#define O_EYES     "eyes"
#define O_HEART    "heart"
#define O_LUNGS    "lungs"
#define O_BRAIN    "brain"
#define O_LIVER    "liver"
#define O_KIDNEYS  "kidneys"
#define O_APPENDIX "appendix"

#define TARGET_ZONE_ALL list(BP_CHEST, BP_GROIN, BP_HEAD, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, O_EYES, O_MOUTH)

#define LEFT  1
#define RIGHT 2

//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock

//Vomit
#define DEFAULT_VOMIT 0
#define VOMIT_TOXIC 1
#define VOMIT_BLOOD 2
#define VOMIT_NANITE 3

//intent defines
#define INTENT_HELP   "help"
#define INTENT_GRAB   "grab"
#define INTENT_PUSH   "push"
#define INTENT_HARM   "harm"
//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

// Species Names (keep in mind, that whitelist and preferences DB depends on this names too, and if anything is renamed, update MYSQL tables or is_alien_whitelisted() proc and preferences).
#define HUMAN          	 "Human"
#define UNATHI         	 "Unathi"
#define TAJARAN        	 "Tajaran"
#define SKRELL         	 "Skrell"
#define DIONA          	 "Diona"
#define PODMAN         	 "Podman"
#define IPC            	 "Machine"
#define VOX            	 "Vox"
#define VOX_ARMALIS    	 "Vox Armalis"
#define ABDUCTOR       	 "Abductor"
#define SKELETON       	 "Skeleton"
#define SKELETON_UNATHI	 "Skeleton Unathi"
#define SKELETON_TAJARAN "Skeleton Tajaran"
#define SKELETON_SKRELL	 "Skeleton Skrell"
#define SKELETON_VOX	 "Skeleton Vox"
#define SHADOWLING     	 "Shadowling"
#define GOLEM          	 "Adamantine Golem"
#define HOMUNCULUS     	 "Homunculus"
#define ZOMBIE         	 "Zombie"
#define ZOMBIE_TAJARAN 	 "Zombie Tajaran"
#define ZOMBIE_SKRELL  	 "Zombie Skrell"
#define ZOMBIE_UNATHI  	 "Zombie Unathi"
#define SLIME          	 "Slime"
#define ABOMINATION    	 "disgusting abomination"

#define MONKEY         	 "Monkey"

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.

#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up

//Threshold levels for beauty for humans
#define BEAUTY_LEVEL_HORRID -66
#define BEAUTY_LEVEL_BAD -33
#define BEAUTY_LEVEL_DECENT 33
#define BEAUTY_LEVEL_GOOD 66
#define BEAUTY_LEVEL_GREAT 100

//Moods levels for humans
#define MOOD_LEVEL_HAPPY4 15
#define MOOD_LEVEL_HAPPY3 10
#define MOOD_LEVEL_HAPPY2 6
#define MOOD_LEVEL_HAPPY1 2
#define MOOD_LEVEL_NEUTRAL 0
#define MOOD_LEVEL_SAD1 -3
#define MOOD_LEVEL_SAD2 -7
#define MOOD_LEVEL_SAD3 -15
#define MOOD_LEVEL_SAD4 -20

//Spirit levels for humans
#define SPIRIT_MAXIMUM 150
#define SPIRIT_HIGH 125
#define SPIRIT_NEUTRAL 100
#define SPIRIT_DISTURBED 75
#define SPIRIT_POOR 50
#define SPIRIT_LOW 25
#define SPIRIT_BAD 0

//Telekinesis.
#define TK_MAXRANGE 15

// Drugs increase the level by 1.
#define TK_LEVEL_ZERO 0
#define TK_LEVEL_ONE 1
#define TK_LEVEL_TWO 2
#define TK_LEVEL_THREE 3
#define TK_LEVEL_FOUR 4

#define TK_LEVEL_NORMAL 1
#define TK_LEVEL_SKRELL 2

// Being drugged improves your telekinesis by a level.
#define TK_BONUS_DRUGGED 1
// Being very desperate/angry/upset improves your telekinesis by a level.
#define TK_BONUS_UPSET 1

// How much resource should be wasted per tile of distance to target.
#define TK_MANA_PER_TILE 1
// How much resource should be wasted per upping of a size class of target.
#define TK_MANA_PER_W_CLASS(cl) (2**cl)

//Nutrition levels for humans.
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_NORMAL 400
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150

#define NUTRITION_PERCENT_MAX 120
#define NUTRITION_PERCENT_ZERO 0

// Drunknenness levels and their effects.
#define DRUNKENNESS_SLUR 30
#define DRUNKENNESS_CONFUSED 150
#define DRUNKENNESS_BLUR 400
#define DRUNKENNESS_PASS_OUT 600

// How many units of reagent are consumed per tick, by default.
#define REAGENTS_METABOLISM 0.2

// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4

// Factor of how fast mob nutrition decreases
#define METABOLISM_FACTOR 1 // standart (for humans, other)

// Taste sensitivity - the more the more reagents you'll taste
#define TASTE_SENSITIVITY_NORMAL 1
#define TASTE_SENSITIVITY_SHARP 1.5
#define TASTE_SENSITIVITY_DULL 0.75
#define TASTE_SENSITIVITY_NO_TASTE 0

// Roundstart "trait" system
#define MAX_QUIRKS 6 // The maximum amount of quirks one character can have at roundstart

//Ian can lick or sniff
#define IAN_STANDARD 0
#define IAN_LICK     1
#define IAN_SNIFF    2

// CLicks Cooldowns
#define CLICK_CD_MELEE 8
#define CLICK_CD_INTERACT 4
#define CLICK_CD_RAPID 2
#define CLICK_CD_AI 9
#define CLICK_CD_GRAB 40
#define CLICK_CD_ACTION 20 // used in grab actions

#define NO_SLIP_WHEN_WALKING (1<<0)
#define SLIDE                (1<<1)
#define GALOSHES_DONT_HELP   (1<<2)
#define SLIDE_ICE            (1<<3)

//movement intent defines for the m_intent var
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

// Indicators.
#define IND_STAT          "stat"
#define IND_STAT_NOCLIENT "stat_noclient"

// Heart status
#define HEART_NORMAL      "heart_normal"
#define HEART_FAILURE     "heart_failure"
#define HEART_FIBR        "heart_fibrillation"

// Defibrillation
#define DEFIB_TIME_LIMIT  (8 MINUTES) //past this many seconds, defib is useless. Currently 8 Minutes
#define DEFIB_TIME_LOSS   (2 MINUTES) //past this many seconds, brain damage occurs. Currently 2 minutes
#define MAX_BRAIN_DAMAGE  80

// Awareness about syndicate, it`s agents and equipment
#define SYNDICATE_UNAWARE  0
#define SYNDICATE_PHRASES  1
#define SYNDICATE_RESPONSE 2
#define SYNDICATE_AWARE    3

#define HUMANHEIGHT_SHORTEST "shortest height"
#define HUMANHEIGHT_SHORT    "short height"
#define HUMANHEIGHT_MEDIUM   "medium height"
#define HUMANHEIGHT_TALL     "tall height"
#define HUMANHEIGHT_TALLEST  "tallest height"

// How much of the reagent needs to be ingested before moving onto the next stage.
#define ALLERGY_NONE 0
#define ALLERGY_UNDISCOVERED 1
#define ALLERGY_DISCOVERED 5
#define ALLERGY_LETHAL 7

#define ALLERGY_SKIN "skin"
#define ALLERGY_INGESTION "ingestion"
// can't implement rn but would be funny
// #define ALLERGY_BREATH 3

// logout reasons
#define LOGOUT_UNKNOWN 0
#define LOGOUT_USER 1
#define LOGOUT_GHOST 2
#define LOGOUT_REENTER 3
#define LOGOUT_SWAP 4 // not so safe, check other things if available
