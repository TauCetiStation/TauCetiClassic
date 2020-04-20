//Damage things
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE     "brute"
#define BURN      "fire"
#define TOX       "tox"
#define OXY       "oxy"
#define CLONE     "clone"
#define HALLOSS   "halloss"

#define CUT       "cut"
#define BRUISE    "bruise"
#define PIERCE    "pierce"
#define LASER     "laser"

#define STUN      "stun"
#define WEAKEN    "weaken"
#define PARALYZE  "paralize"
#define IRRADIATE "irradiate"
#define AGONY     "agony"
#define STUTTER   "stutter"
#define SLUR      "slur"
#define EYE_BLUR  "eye_blur"
#define DROWSY    "drowsy"

// Damage flags
#define DAM_SHARP 1
#define DAM_EDGE  2
#define DAM_LASER 4

// These control the amount of blood lost from burns. The loss is calculated so
// that dealing just enough burn damage to kill the player will cause the given
// proportion of their max blood volume to be lost
// (e.g. 0.6 == 60% lost if 200 burn damage is taken).
#define FLUIDLOSS_WIDE_BURN 0.2 // for burns from heat applied over a wider area, like from fire
#define FLUIDLOSS_CONC_BURN 0.1 // for concentrated burns, like from lasers

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS	1
#define FIRELOSS	2
#define TOXLOSS 	4
#define OXYLOSS 	8

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN		1
#define CANWEAKEN	2
#define CANPARALYSE	4
#define CANPUSH		8
#define LEAPING		16
#define PASSEMOTES	32      //Mob has holders inside of it that need to see emotes.
#define LOCKSTUN	64      // if Mob has this flag, then stunned cannot be modified using Stun() SetStun() AdjustStunned() procs.
#define GODMODE		4096
#define FAKEDEATH	8192	//Replaces stuff like changeling.changeling_fakedeath
#define DISFIGURED	16384	//I'll probably move this elsewhere if I ever get wround to writing a bitflag mob-damage system
#define XENO_HOST	32768	//Tracks whether we're gonna be a baby alien's mummy.
#define MOB_STATUS_FLAGS_DEFAULT (CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH)

//Grab levels
#define GRAB_NONE         0
#define GRAB_PASSIVE      1
#define GRAB_AGGRESSIVE   2
#define GRAB_NECK         3
#define GRAB_KILL         4

#define HOSTILE_STANCE_IDLE 	 1
#define HOSTILE_STANCE_ALERT 	 2
#define HOSTILE_STANCE_ATTACK 	 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 	 5
