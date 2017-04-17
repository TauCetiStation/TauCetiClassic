// Maybe Bay12's inventory port?
// The below should be used to define an item's w_class variable.
// Example: w_class = ITENSIZE_LARGE
// This allows the addition of future w_classes without needing to change every file.
#define ITEM_SIZE_TINY           1
#define ITEM_SIZE_SMALL          2
#define ITEM_SIZE_NORMAL         3
#define ITEM_SIZE_LARGE          4
#define ITEM_SIZE_HUGE           5
#define ITEM_SIZE_GARGANTUAN     6
#define ITEM_SIZE_NO_CONTAINER INFINITY // Use this to forbid item from being placed in a container.

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH		3
#define STORAGE_VIEW_DEPTH	2
