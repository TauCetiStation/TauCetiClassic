#define ALL (~0) //For convenience.
#define NONE 0

var/global/list/bitflags = list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768)

//PREASSURE_FLAGS BITMASK
#define STOPS_HIGHPRESSUREDMAGE 1    //These flags is used on the flags_pressure variable for SUIT and HEAD items which stop (high/low/all) pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_FLAGS_BACK) if you see it anywhere
#define STOPS_LOWPRESSUREDMAGE  2    //To successfully stop you taking all pressure damage you must have both a suit and head item with STOPS_PRESSUREDMAGE flag.
#define STOPS_PRESSUREDMAGE     3    //Used against both, high and low pressure.

#define NOLIMB           -1    // related to "pierce_protection" check, thats why this is here.
#define NOPIERCE         -2    // related to "pierce_protection" check
//FLAGS BITMASK
#define NOBLUDGEON             (1<<1)   // When an item has this it produces no "X has been hit by Y with Z" message with the default handler.

#define BLOCKHEADHAIR          (1<<2)   // Clothing. Temporarily removes the user's hair overlay. Leaves facial hair.

#define MASKINTERNALS          (1<<3)   // Mask allows internals.

#define NOBLOODY               (1<<4)   // Used to items if they don't want to get a blood overlay. Doesn't work properly with shoes.

#define CONDUCT                (1<<5)   // Conducts electricity. (metal etc.)

#define ABSTRACT               (1<<6)   // For all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way.
#define NODECONSTRUCT          (1<<6)   // For machines and structures that should just dissapear when deconstructed without breaking into parts, eg, holodeck stuff.

#define ON_BORDER              (1<<7)   // Item has priority to check when entering or leaving.

#define GLASSESCOVERSEYES      (1<<8)
#define MASKCOVERSEYES         (1<<8)   // Get rid of some of the other retardation in these flags.
#define HEADCOVERSEYES         (1<<8)   // feel free to realloc these numbers for other purposes.

#define MASKCOVERSMOUTH        (1<<9)   // on other items, these are just for mask/head.
#define HEADCOVERSMOUTH        (1<<9)

#define OPENCONTAINER          (1<<10)  // Is an open container for chemistry purposes.

#define BLOCK_GAS_SMOKE_EFFECT (1<<11)  // Blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL         (1<<11)  // Clothing. Acceptable for a fat mob

#define PHORONGUARD            (1<<12)  // Does not get contaminated by phoron.
#define NOREACT                (1<<12)  // Reagents dont' react inside this container.

#define DROPDEL                (1<<13)  // When dropped, it calls qdel on itself

#define NODROP                 (1<<14)  // User can't drop this item

#define BLOCKHAIR              (1<<15)  // Clothing. Temporarily removes the user's hair, facial and otherwise.

#define BLOCKUNIFORM           (1<<16)  // CLothing. Hide uniform overlay.

#define IS_SPINNING            (1<<17)  // Is the thing currently spinning?

#define NOSLIP                 (1<<18)   // Prevents from slipping on wet floors, in space etc.

#define AIR_FLOW_PROTECT       (1<<19)   //  Protects against air flow.

#define NOATTACKANIMATION      (1<<20)   // Removes attack animation

// objects hear flags
// HEAR_PASS_SAY, HEAR_TA_SAY is temporary solution for optimisations reasons before we do hear() code refactoring
#define HEAR_TALK              (1<<21)   // like old tg HEAR_1, marks objects with hear_talk()
#define HEAR_PASS_SAY          (1<<22)   // temp for say code, for objects that need to pass SAY to inner mobs through get_listeners()
#define HEAR_TA_SAY            (1<<23)   // temp for talking_atoms
// !!!!     THERE IS NO MORE BITS, 23 IS LAST     !!!!!
// You can use flags_2, or check this task https://github.com/TauCetiStation/TauCetiClassic/issues/10023

/* Secondary atom flags, for the flags_2 var, denoted with a _2 */
#define HOLOGRAM_2         (1<<0)
/// atom queued to SSoverlay
#define OVERLAY_QUEUED_2       (1<<1)
/// atom with this flag will never appear on demo
#define PROHIBIT_FOR_DEMO_2          (1<<2)
/// atom overlays with this flag will never appear on demo
#define PROHIBIT_OVERLAYS_FOR_DEMO_2 (1<<3)

#define IN_INVENTORY           (1<<4)
#define IN_STORAGE             (1<<5)
#define CANT_BE_INSERTED       (1<<6)   // Prohibits putting an item in a containers
//alternate appearance flags
#define AA_TARGET_SEE_APPEARANCE (1<<0)
#define AA_MATCH_TARGET_OVERLAYS (1<<1)

//Species flags.
#define NO_BLOOD           "no_blood"
#define NO_BREATHE         "no_breathe"
#define NO_SCAN            "no_scan"
#define NO_PAIN            "no_pain"
#define NO_EMBED           "no_embed"
#define NO_FAT             "no_fatness"
#define HAS_SKIN_TONE      "has_skin_tone"
#define HAS_SKIN_COLOR     "has_skin_color"
#define HAS_HAIR_COLOR     "has_hair_color"
#define HAS_LIPS           "has_lips"
#define HAS_UNDERWEAR      "has_underwear"
#define HAS_TAIL           "has_tail"
#define IS_SOCIAL          "is_social"
#define IS_PLANT           "is_plant"
#define IS_WHITELISTED     "is_whitelisted"
#define RAD_ABSORB         "rad_absorb"
#define REQUIRE_LIGHT      "require_light"
#define IS_SYNTHETIC       "is_synthetic"
#define RAD_IMMUNE         "rad_immune"
#define VIRUS_IMMUNE       "virus_immune"
#define NO_VOMIT           "no_vomit"
#define HAS_HAIR           "has_hair"
#define NO_FINGERPRINT     "no_fingerprint"
#define NO_MINORCUTS	   "no_minorcuts"
#define NO_BLOOD_TRAILS    "no_blood_trails"
#define FACEHUGGABLE       "facehuggable"
#define NO_EMOTION         "no_emotion"
#define NO_DNA             "no_dna"
#define FUR                "fur"
#define NO_GENDERS         "no_genders"
#define NO_SLIP            "no_slip"
#define NO_MED_HEALTH_SCAN "no_med_health_scan"

//Species Diet Flags
#define DIET_MEAT		1 // Meat.
#define DIET_PLANT		2 // Vegans!
#define DIET_DAIRY		4 // Milk, everything made out of milk.
#define DIET_OMNI       7 // Everything.
#define DIET_ALL		DIET_OMNI

//Reagent Flags
#define IS_ORGANIC         "is_organic"

//bitflags for door switches.
#define OPEN     1
#define CLOSED   2 //for firedoor currently, legacy and should be checked
#define IDSCAN   2
#define BOLTS    4
#define SHOCK    8
#define SAFE    16

//flags for pass_flags
#define PASSTABLE    1
#define PASSGLASS    2
#define PASSGRILLE   4
#define PASSBLOB     8
#define PASSCRAWL   16
#define PASSMOB     32

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF (1<<0)
/// 100% immune to fire damage (but not necessarily to lava or heat)
#define FIRE_PROOF (1<<1)
#define FLAMMABLE (1<<2)
/// acid can't even appear on it, let alone melt it.
#define UNACIDABLE (1<<4)
/// acid stuck on it doesn't melt it.
#define ACID_PROOF (1<<5)
/// doesn't take damage
#define INDESTRUCTIBLE (1<<6)
/// can't be deconstructed with instruments
#define DECONSTRUCT_IMMUNE (1<<7)
/// can be hit with melee (mb change to CANT_BE_HIT)
#define CAN_BE_HIT (1<<8)

#define FULL_INDESTRUCTIBLE INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | DECONSTRUCT_IMMUNE

//turf-only flags
#define NOSTEPSOUND   1

//flags for customizing id-cards
#define FORDBIDDEN_VIEW      1
#define UNIVERSAL_VIEW       2
#define TRAITOR_VIEW         4

// changeling essences flags
#define ESSENCE_SPEAK 1
#define ESSENCE_WHISP 2
#define ESSENCE_SPEAK_IN_RADIO 4
#define ESSENCE_HIVEMIND 8
#define ESSENCE_SPEAK_TO_HOST 16
#define ESSENCE_SELF_VOICE 32
#define ESSENCE_PHANTOM 64
#define ESSENCE_POINT 128
#define ESSENCE_EMOTE 256
#define ESSENCE_ALL 511

// Jobs flags
#define JOB_FLAG_SECURITY 1
#define JOB_FLAG_COMMAND 2
#define JOB_FLAG_ENGINEERING 4
#define JOB_FLAG_MEDBAY 8
#define JOB_FLAG_CIVIL 16
#define JOB_FLAG_CARGO 32
#define JOB_FLAG_SCIENCE 64
#define JOB_FLAG_NON_HUMAN 128
#define JOB_FLAG_HEAD_OF_STAFF 256
#define JOB_FLAG_BLUESHIELD_PROTEC 512
#define JOB_FLAG_CENTCOMREPRESENTATIVE 1024

//dir macros
///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))

// Holomap flags
#define HOLOMAP_DEATHSQUAD_COLOR "#800000"
#define HOLOMAP_NUCLEAR_COLOR "#e30000"
#define HOLOMAP_VOX_COLOR "#3bcccc"
#define HOLOMAP_ERT_COLOR "#0b74b4"
#define HOLOMAP_TEAM_COLOR "#00bb00"

#define IS_EPILEPTIC_NOT_IN_PARALYSIS (1<<0)

#define EPILEPSY_PARALYSE_EFFECT (1<<0)
#define EPILEPSY_JITTERY_EFFECT (1<<1)

#define ALCOHOL_TOLERANCE_EPILEPSY (1<<0)
#define WATER_CHOKE_EPILEPSY (1<<1)

#define STANDARD_PDA_RINGTONE (1<<0)
