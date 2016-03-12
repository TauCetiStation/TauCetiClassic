//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 1	//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
                                //To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define TABLEPASS 2				// can pass by a table or rack

#define MASKINTERNALS	8	// mask allows internals
//#define SUITSPACE		8	// suit protects against space

#define USEDELAY 		16		// 1 second extra delay on use (Can be used once every 2s)
#define NODELAY 		32768	// 1 second attackby delay skipped (Can be used once every 0.2s). Most objects have a 1s attackby delay, which doesn't require a flag.
#define NOSHIELD		32		// weapon not affected by shield
#define CONDUCT			64		// conducts electricity (metal etc.)
#define FPRINT			256		// takes a fingerprint
#define ON_BORDER		512		// item has priority to check when entering or leaving
#define NOBLUDGEON		4		// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define NOBLOODY		2048	// used to items if they don't want to get a blood overlay
#define ABSTRACT		128		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define NODECONSTRUCT	128		// For machines and structures that should not break into parts, eg, holodeck stuff

#define GLASSESCOVERSEYES	1024
#define MASKCOVERSEYES		1024		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		1024		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		2048		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		2048

#define THICKMATERIAL	1024		//From /tg: prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with NOSLIP for shoes)
#define NOSLIP			1024 		//prevents from slipping on wet floors, in space etc

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

#define BLOCK_GAS_SMOKE_EFFECT	8192	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL			8192
#define PHORONGUARD				16384			//Does not get contaminated by phoron.

#define	NOREACT		16384 			//Reagents dont' react inside this container.

//Species flags.
#define NO_BLOOD		1
#define NO_BREATHE		2
#define NO_SCAN			4
#define NO_PAIN			8
#define HAS_SKIN_TONE	16
#define HAS_SKIN_COLOR	32
#define HAS_LIPS		64
#define HAS_UNDERWEAR	128
#define HAS_TAIL		256
#define IS_PLANT		512
#define IS_WHITELISTED	1024
#define RAD_ABSORB		2048
#define REQUIRE_LIGHT	4096
#define IS_SYNTHETIC	8192
#define RAD_IMMUNE		16384
#define VIRUS_IMMUNE	32768

//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

//flags for pass_flags
#define PASSTABLE	1
#define PASSGLASS	2
#define PASSGRILLE	4
#define PASSBLOB	8
#define PASSCRAWL	16
#define PASSMOB		32

//turf-only flags
#define NOJAUNT		1

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING		1
#define SLOT_ICLOTHING 		2
#define SLOT_GLOVES 		4
#define SLOT_EYES 			8
#define SLOT_EARS 			16
#define SLOT_MASK 			32
#define SLOT_HEAD 			64
#define SLOT_FEET 			128
#define SLOT_ID 			256
#define SLOT_BELT 			512
#define SLOT_BACK 			1024
#define SLOT_POCKET 		2048	//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 	4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS 		8192
#define SLOT_LEGS 			16384