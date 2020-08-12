#define ALL (~0) //For convenience.
#define NONE 0

//PREASSURE_FLAGS BITMASK
#define STOPS_HIGHPRESSUREDMAGE 1    //These flags is used on the flags_pressure variable for SUIT and HEAD items which stop (high/low/all) pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_FLAGS_BACK) if you see it anywhere
#define STOPS_LOWPRESSUREDMAGE  2    //To successfully stop you taking all pressure damage you must have both a suit and head item with STOPS_PRESSUREDMAGE flag.
#define STOPS_PRESSUREDMAGE     3    //Used against both, high and low pressure.

#define NOLIMB           -1    // related to THICKMATERIAL check, thats why this is here.
//FLAGS BITMASK
#define NOBLUDGEON             (1<<1)   // When an item has this it produces no "X has been hit by Y with Z" message with the default handler.

#define BLOCKHEADHAIR          (1<<2)   // Clothing. Temporarily removes the user's hair overlay. Leaves facial hair.
#define MASKINTERNALS          (1<<2)   // Mask allows internals.

//#define USEDELAY             (1<<3)   // 1 second extra delay on use. (Can be used once every 2s) ~ Kursh, Doesn't used for now.
#define NOSHIELD               (1<<4)   // Weapon not affected by shield.

#define CONDUCT                (1<<5)   // Conducts electricity. (metal etc.)

#define ABSTRACT               (1<<6)   // For all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way.
#define NODECONSTRUCT          (1<<6)   // For machines and structures that should not break into parts, eg, holodeck stuff.

#define ON_BORDER              (1<<7)   // Item has priority to check when entering or leaving.

#define THICKMATERIAL          (1<<8)   // Prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with NOSLIP for shoes)
#define GLASSESCOVERSEYES      (1<<8)
#define MASKCOVERSEYES         (1<<8)   // Get rid of some of the other retardation in these flags.
#define HEADCOVERSEYES         (1<<8)   // feel free to realloc these numbers for other purposes.

#define MASKCOVERSMOUTH        (1<<9)   // on other items, these are just for mask/head.
#define HEADCOVERSMOUTH        (1<<9)
#define NOBLOODY               (1<<9)   // Used to items if they don't want to get a blood overlay.
#define NOSLIP                 (1<<9)   // Prevents from slipping on wet floors, in space etc.
#define NOATTACKANIMATION      (1<<9)   // Removes attack animation

#define OPENCONTAINER          (1<<10)  // Is an open container for chemistry purposes.

#define BLOCK_GAS_SMOKE_EFFECT (1<<11)  // Blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL         (1<<11)  // Clothing. Acceptable for a fat mob

#define PHORONGUARD            (1<<12)  // Does not get contaminated by phoron.
#define NOREACT                (1<<12)  // Reagents dont' react inside this container.

#define DROPDEL                (1<<13)  // When dropped, it calls qdel on itself

#define NODROP                 (1<<14)  // User can't drop this item

#define BLOCKHAIR              (1<<15)  // Clothing. Temporarily removes the user's hair, facial and otherwise.

#define BLOCKUNIFORM           (1<<16)  // CLothing. Hide uniform overlay.

/* Secondary atom flags, for the flags_2 var, denoted with a _2 */
#define HOLOGRAM_2         (1<<0)
/// atom queued to SSoverlay
#define OVERLAY_QUEUED_2   (1<<1)

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
#define IS_PLANT           "is_plant"
#define IS_WHITELISTED     "is_whitelisted"
#define RAD_ABSORB         "rad_absorb"
#define REQUIRE_LIGHT      "require_light"
#define IS_SYNTHETIC       "is_synthetic"
#define RAD_IMMUNE         "rad_immune"
#define VIRUS_IMMUNE       "virus_immune"
#define BIOHAZZARD_IMMUNE  "biohazzard_immune"
#define NO_VOMIT           "no_vomit"
#define HAS_HAIR           "has_hair"
#define NO_FINGERPRINT     "no_fingerprint"
#define NO_MINORCUTS	   "no_minorcuts"
#define NO_BLOOD_TRAILS    "no_blood_trails"
#define FACEHUGGABLE       "facehuggable"
#define NO_EMOTION         "no_emotion"
#define NO_DNA             "no_dna"
#define SPRITE_SHEET_RESTRICTION "sprite_sheet_restriction" // If specie has this flag, all clothing which icon_state is in the sprite sheet will be awearable.

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

//turf-only flags
#define NOJAUNT  1

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
