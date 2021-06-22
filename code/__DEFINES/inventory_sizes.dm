// The below should be used to define an item's w_class variable.
// Example: w_class = SIZE_SMALL
// This allows the addition of future w_classes without needing to change every file.
#define SIZE_MINUSCULE  1  //ex ITEM_SIZE_TINY Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define SIZE_TINY       2  //ex ITEM_SIZE_SMALL Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define SIZE_SMALL      3  //ex ITEM_SIZE_NORMAL Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define SIZE_NORMAL     4  //ex ITEM_SIZE_LARGE Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define SIZE_LARGE      5  //ex ITEM_SIZE_HUGE Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define SIZE_HUGE       6  //ex ITEM_SIZE_GARGANTUAN Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe's
#define SIZE_HUMAN      7  //Human
#define SIZE_GAINT      8  //Hulk & Mech
#define SIZE_GYGANT     9  //Alien Queen
#define SIZE_GARGANTUAN 10 //NARSIE
#define SIZE_NO_CONTAINER INFINITY //ex ITEM_SIZE_NO_CONTAINER Use this to forbid item from being placed in a container.

#define base_storage_cost(w_class) (2**(w_class-1)) //1,2,4,8,16,...

//linear increase. Using many small storage containers is more space-efficient than using large ones,
//in exchange for being limited in the w_class of items that will fit
#define base_storage_capacity(w_class) (7*(w_class-1))

#define DEFAULT_BACKPACK_STORAGE base_storage_capacity(5)
#define DEFAULT_LARGEBOX_STORAGE base_storage_capacity(4)
#define DEFAULT_BOX_STORAGE base_storage_capacity(3)
