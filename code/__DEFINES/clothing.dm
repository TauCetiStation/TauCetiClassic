//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES		1	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE	2	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT	4	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES		8	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDETAIL 		16	//APPLIES ONLY TO THE EXTERIOR SUIT!!

#define HIDEMASK	1	//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDEEARS	2	//APPLIES ONLY TO HELMETS/MASKS!! (ears means headsets and such)
#define HIDEEYES	4	//APPLIES ONLY TO HELMETS/MASKS!! (eyes means glasses)
#define HIDEFACE	8	//APPLIES ONLY TO HELMETS/MASKS!! Dictates whether we appear as unknown.

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_FLAGS_OCLOTHING    (1<<0)
#define SLOT_FLAGS_ICLOTHING    (1<<1)
#define SLOT_FLAGS_GLOVES       (1<<2)
#define SLOT_FLAGS_EYES         (1<<3)
#define SLOT_FLAGS_EARS         (1<<4)
#define SLOT_FLAGS_MASK         (1<<5)
#define SLOT_FLAGS_HEAD         (1<<6)
#define SLOT_FLAGS_FEET         (1<<7)
#define SLOT_FLAGS_ID           (1<<8)
#define SLOT_FLAGS_BELT         (1<<9)
#define SLOT_FLAGS_BACK         (1<<10)
#define SLOT_FLAGS_POCKET       (1<<11)    // This is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_FLAGS_DENYPOCKET   (1<<12)    // This is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_FLAGS_TWOEARS      (1<<13)
#define SLOT_FLAGS_TIE          (1<<14)

//slots
#define slot_back        1
#define slot_wear_mask   2
#define slot_handcuffed  3
#define slot_l_hand      4
#define slot_r_hand      5
#define slot_belt        6
#define slot_wear_id     7
#define slot_l_ear       8
#define slot_glasses     9
#define slot_gloves      10
#define slot_head        11
#define slot_shoes       12
#define slot_wear_suit   13
#define slot_w_uniform   14
#define slot_l_store     15
#define slot_r_store     16
#define slot_s_store     17
#define slot_in_backpack 18
#define slot_legcuffed   19
#define slot_r_ear       20
#define slot_legs        21
#define slot_tie         22

//Sol translation for dog slots.
#define slot_mouth slot_wear_mask  // 2
#define slot_neck  slot_handcuffed // 3 (Ian actually is a cat! ~if you know what i mean)

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD			1
#define FACE			2
#define EYES			4
#define UPPER_TORSO		8
#define LOWER_TORSO		16
#define LEG_LEFT		32
#define LEG_RIGHT		64
#define LEGS			96
#define ARM_LEFT		512
#define ARM_RIGHT		1024
#define ARMS			1536
#define FULL_BODY		1663

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_UPPER_TORSO	0.15
#define THERMAL_PROTECTION_LOWER_TORSO	0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075

// Suit sensor levels
#define SUIT_SENSOR_OFF      0
#define SUIT_SENSOR_BINARY   1
#define SUIT_SENSOR_VITAL    2
#define SUIT_SENSOR_TRACKING 3

#define BLOCKHEADHAIR 4             // temporarily removes the user's hair overlay. Leaves facial hair.
#define BLOCKHAIR	32768			// temporarily removes the user's hair, facial and otherwise.

// Cutting shoes flags

#define NO_CLIPPING   -1
#define CLIPPABLE      0
#define CLIPPED        1

// attack_reaction types
#define REACTION_INTERACT_UNARMED 0
#define REACTION_INTERACT_ARMED 1
#define REACTION_GUN_FIRE 2
#define REACTION_ITEM_TAKE 3
#define REACTION_ITEM_TAKEOFF 4
#define REACTION_HIT_BY_BULLET 5
#define REACTION_ATACKED 6
#define REACTION_THROWITEM 7
