// The below should be used to define an item's w_class variable.
// Example: w_class = ITEM_SIZE_NORMAL
// This allows the addition of future w_classes without needing to change every file.
#define ITEM_SIZE_TINY           1 //Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define ITEM_SIZE_SMALL          2 //Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define ITEM_SIZE_NORMAL         3 //Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define ITEM_SIZE_LARGE          4 //Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define ITEM_SIZE_HUGE           5 //Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define ITEM_SIZE_GARGANTUAN     6 //Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe
#define ITEM_SIZE_NO_CONTAINER INFINITY // Use this to forbid item from being placed in a container.