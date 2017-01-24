//PREASSURE_FLAGS BITMASK
#define STOPS_PRESSUREDMAGE     1    //This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
                                     //To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
                                     //Used against both, high and low pressure.
#define STOPS_HIGHPRESSUREDMAGE 2
#define STOPS_LOWPRESSUREDMAGE  4

//FLAGS BITMASK
#define NOBLUDGEON        2    // When an item has this it produces no "X has been hit by Y with Z" message with the default handler.
#define MASKINTERNALS     4    // Mask allows internals.
#define USEDELAY          8    // 1 second extra delay on use. (Can be used once every 2s)
#define NOSHIELD         16    // Weapon not affected by shield.
#define CONDUCT          32    // Conducts electricity. (metal etc.)
#define ABSTRACT         64    // For all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way.
#define NODECONSTRUCT    64    // For machines and structures that should not break into parts, eg, holodeck stuff.
#define ON_BORDER       128    // Item has priority to check when entering or leaving.
#define THICKMATERIAL   256    // Prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with NOSLIP for shoes)
#define NOSLIP          256    // Prevents from slipping on wet floors, in space etc.

#define GLASSESCOVERSEYES   256
#define MASKCOVERSEYES      256    // Get rid of some of the other retardation in these flags.
#define HEADCOVERSEYES      256    // feel free to realloc these numbers for other purposes.
#define MASKCOVERSMOUTH     512    // on other items, these are just for mask/head.
#define HEADCOVERSMOUTH     512

#define NOBLOODY  512    // Used to items if they don't want to get a blood overlay.

#define OPENCONTAINER  1024    // Is an open container for chemistry purposes.

#define BLOCK_GAS_SMOKE_EFFECT  2048    // Blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL          2048
#define PHORONGUARD             4096    // Does not get contaminated by phoron.

#define	NOREACT  4096    //Reagents dont' react inside this container.

//Species flags.
#define NO_BLOOD           "no_blood"
#define NO_BREATHE         "no_breathe"
#define NO_SCAN            "no_scan"
#define NO_PAIN            "no_pain"
#define HAS_SKIN_TONE      "has_skin_tone"
#define HAS_SKIN_COLOR     "has_skin_color"
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
#define HAS_HAIR           "has_hair"

//bitflags for door switches.
#define OPEN     1
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

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING       1
#define SLOT_ICLOTHING       2
#define SLOT_GLOVES          4
#define SLOT_EYES            8
#define SLOT_EARS           16
#define SLOT_MASK           32
#define SLOT_HEAD           64
#define SLOT_FEET          128
#define SLOT_ID            256
#define SLOT_BELT          512
#define SLOT_BACK         1024
#define SLOT_POCKET       2048    // This is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET   4096    // This is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS      8192
#define SLOT_LEGS        16384
