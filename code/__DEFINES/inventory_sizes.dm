// The below should be used to define an item's w_class variable.
// Example: w_class = SIZE_SMALL
// This allows the addition of future w_classes without needing to change every file.

// Transition list in case if you need to port code with old classes:
// ITEM_SIZE_TINY -> SIZE_MINUSCULE
// ITEM_SIZE_SMALL -> SIZE_TINY
// ITEM_SIZE_NORMAL -> SIZE_SMALL
// ITEM_SIZE_BIG -> SIZE_NORMAL
// ITEM_SIZE_LARGE -> SIZE_BIG

#define SIZE_MINUSCULE  1  // Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define SIZE_TINY       2  // Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define SIZE_SMALL      3  // ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define SIZE_NORMAL     4  // Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define SIZE_BIG        5  // Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define SIZE_LARGE      6  // Items of this class and above can't be placed in backpacks, ex: Mech Parts, Safe's
#define SIZE_HUMAN      7  // ex: Human
#define SIZE_MASSIVE    8  // ex: Hulk & Mech
#define SIZE_GYGANT     9  // ex: Alien Queen
#define SIZE_GARGANTUAN 10 // ex: NARSIE

#define SIZE_ABSTRACT   INFINITY // default class to forbid items without size from being placed in a container

#define base_storage_cost(w_class) (2**(w_class-1)) //1,2,4,8,16,...

//linear increase. Using many small storage containers is more space-efficient than using large ones,
//in exchange for being limited in the w_class of items that will fit
#define base_storage_capacity(w_class) (7*(w_class-1))

#define DEFAULT_BACKPACK_STORAGE base_storage_capacity(5)
#define DEFAULT_LARGEBOX_STORAGE base_storage_capacity(4)
#define DEFAULT_BOX_STORAGE base_storage_capacity(3)
