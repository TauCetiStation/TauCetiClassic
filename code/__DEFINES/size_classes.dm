/* OBJECTS AND MOBS SIZES CLASSES */

// Transition list from old classes:
// ITEM_SIZE_TINY -> SIZE_MINUSCULE
// ITEM_SIZE_SMALL -> SIZE_TINY
// ITEM_SIZE_NORMAL -> SIZE_SMALL
// ITEM_SIZE_LARGE -> SIZE_NORMAL
// ITEM_SIZE_HUGE -> SIZE_BIG

// mob.small -> SIZE_MINUSCULE or SIZE_TINY

#define SIZE_MIDGET     0.5 // Size of chips and other snacks
#define SIZE_MINUSCULE  1   // Usually items smaller then a human hand, ex: Mouse, Playing Cards, Lighter, Scalpel, Coins/Money
#define SIZE_TINY       2   // Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define SIZE_SMALL      3   // ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define SIZE_NORMAL     4   // Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define SIZE_BIG        5   // Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define SIZE_LARGE      6   // Items of this class and above can't be placed in backpacks, ex: Mech Parts, Safe's
#define SIZE_HUMAN      7   // ex: Human
#define SIZE_BIG_HUMAN  8   // ex: FAT Human
#define SIZE_MASSIVE    9   // ex: Hulk & Mech
#define SIZE_GYGANT     10  // ex: Alien Queen
#define SIZE_GARGANTUAN 11  // should be last define, ex: NARSIE

/* OBJECTS STORAGE CALCULATIONS */

#define base_storage_cost(w_class) (2**(w_class-1)) //1,2,4,8,16,...

//linear increase. Using many small storage containers is more space-efficient than using large ones,
//in exchange for being limited in the w_class of items that will fit
#define base_storage_capacity(w_class) (7*(w_class-1))

#define DEFAULT_BACKPACK_STORAGE base_storage_capacity(5)
#define DEFAULT_LARGEBOX_STORAGE base_storage_capacity(4)
#define DEFAULT_BOX_STORAGE base_storage_capacity(3)

/* SINGULARITY STAGES */

// todo: should be adapted and merged with common size classes above
#define STAGE_ONE    1
#define STAGE_TWO    3
#define STAGE_THREE  5
#define STAGE_FOUR   7
#define STAGE_FIVE   9
#define STAGE_SIX    11 //From supermatter shard
// and narsie/large has current_size = 12
