// Maybe Bay12's inventory port?
// The below should be used to define an item's w_class variable.
// Example: w_class = ITENSIZE_LARGE
// This allows the addition of future w_classes without needing to change every file.
#define ITEM_SIZE_TINY         1
#define ITEM_SIZE_SMALL        2
#define ITEM_SIZE_NORMAL       3
#define ITEM_SIZE_LARGE        4
#define ITEM_SIZE_HUGE         5
#define ITEM_SIZE_GARGANTUAN   6
#define ITEM_SIZE_NO_CONTAINER INFINITY // Use this to forbid item from being placed in a container.

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH    3
#define STORAGE_VIEW_DEPTH 2

//Inventory slot names and defines, mostly used as arg for inventory procs.
#define slot_back         "back"
#define slot_wear_mask    "mask"
#define slot_handcuffed   "handcuffs"
#define slot_l_hand       "left hand"
#define slot_r_hand       "right hand"
#define slot_belt         "belt"
#define slot_wear_id      "id"
#define slot_l_ear        "left ear"
#define slot_glasses      "eyes"
#define slot_gloves       "gloves"
#define slot_head         "head"
#define slot_shoes        "shoes"
#define slot_wear_suit    "suit"
#define slot_w_uniform    "uniform"
#define slot_l_store      "left store"
#define slot_r_store      "right store"
#define slot_s_store      "suit store"
#define slot_in_backpack  "18"
#define slot_legcuffed    "shackles"
#define slot_r_ear        "right ear"
#define slot_undershirt   "undershirt"
#define slot_underwear    "underwear"
#define slot_socks        "socks"

//Sol translation for dog slots.
#define slot_mouth        slot_wear_mask  // 2
#define slot_neck         slot_handcuffed // 3
