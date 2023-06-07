//Damage things
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE     "brute"
#define BURN      "fire"
#define TOX       "tox"
#define OXY       "oxy"
#define CLONE     "clone"
#define HALLOSS   "halloss"

//Damage flag defines //
/// Involves a melee attack or a thrown object.
#define MELEE "melee"
/// Involves a solid projectile.
#define BULLET "bullet"
/// Involves a laser.
#define LASER "laser"
/// Involves an EMP or energy-based projectile.
#define ENERGY "energy"
/// Involves a shockwave, usually from an explosion.
#define BOMB "bomb"
/// Involved in checking wheter a disease can infect or spread. Also involved in xeno neurotoxin.
#define BIO "bio"
/// Involves fire or temperature extremes.
#define FIRE "fire"
/// Involves corrosive substances.
#define ACID "acid"
/// Involved in checking the likelyhood of applying a wound to a mob.
#define WOUND "wound"
/// Involves being eaten
#define CONSUME "consume"

#define CUT       "cut"
#define BRUISE    "bruise"
#define PIERCE    "pierce"

#define STUN      "stun"
#define WEAKEN    "weaken"
#define PARALYZE  "paralize"
#define IRRADIATE "irradiate"
#define AGONY     "agony"
#define STUTTER   "stutter"
#define SLUR      "slur"
#define EYE_BLUR  "eye_blur"
#define DROWSY    "drowsy"

// Attack visual effects
#define ATTACK_EFFECT_SMASH  "smash"
#define ATTACK_EFFECT_PUNCH  "punch"
#define ATTACK_EFFECT_BITE   "bite"
#define ATTACK_EFFECT_CLAW   "claw"
#define ATTACK_EFFECT_SLASH  "slash"
#define ATTACK_EFFECT_KICK   "kick"
#define ATTACK_EFFECT_DISARM "disarm"
#define ATTACK_EFFECT_SLIME  "glomp"

//the define for visible message range in combat
#define COMBAT_MESSAGE_RANGE 3

// Damage flags
#define DAM_SHARP 1
#define DAM_EDGE  2
#define DAM_LASER 4

//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

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
#define CANSTUN		1       // Can be stunned
#define CANWEAKEN	2       // Can be weakened
#define CANPARALYSE	4       // Can be paralysed
#define CANPUSH		8       // Can be pushed
#define LEAPING		16
#define PASSEMOTES	32      //Mob has holders inside of it that need to see emotes.

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

// Combo system.
// Sources of movesets.
#define MOVESET_JOB "moveset_job"
#define MOVESET_SPECIES "moveset_species"
#define MOVESET_TYPE "moveset_type"
#define MOVESET_ROLES "moveset_role"
#define MOVESET_QUALITY "moveset_quality"
