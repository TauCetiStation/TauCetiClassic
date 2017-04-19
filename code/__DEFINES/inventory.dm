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
#define slot_back         "1"
#define slot_wear_mask    "2"
#define slot_handcuffed   "3"
#define slot_l_hand       "4"
#define slot_r_hand       "5"
#define slot_belt         "6"
#define slot_wear_id      "7"
#define slot_l_ear        "8"
#define slot_glasses      "9"
#define slot_gloves       "10"
#define slot_head         "11"
#define slot_shoes        "12"
#define slot_wear_suit    "13"
#define slot_w_uniform    "14"
#define slot_l_store      "15"
#define slot_r_store      "16"
#define slot_s_store      "17"
#define slot_in_backpack  "18"
#define slot_legcuffed    "19"
#define slot_r_ear        "20"
#define slot_legs         "21"
#define slot_undershirt   "22"
#define slot_underwear    "23"
#define slot_socks        "24"

//Sol translation for dog slots.
#define slot_mouth        slot_wear_mask  // 2
#define slot_neck         slot_handcuffed // 3
