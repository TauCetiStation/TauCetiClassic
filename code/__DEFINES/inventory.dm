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

//Inventory slot defines (don't forget to update /parse_slot_name() proc).
#define slot_head          "head"
#define slot_l_ear         "l_ear"
#define slot_r_ear         "r_ear"
#define slot_glasses       "glasses"
#define slot_wear_mask     "wear_mask"
#define slot_w_uniform     "w_uniform"
#define slot_wear_suit     "wear_suit"
#define slot_gloves        "gloves"
#define slot_shoes         "shoes"
#define slot_back          "back"
#define slot_belt          "belt"
#define slot_wear_id       "wear_id"
#define slot_l_hand        "l_hand"
#define slot_r_hand        "r_hand"
#define slot_l_store       "l_store"
#define slot_r_store       "r_store"
#define slot_s_store       "s_store"
#define slot_handcuffed    "handcuffed"
#define slot_legcuffed     "legcuffed"
#define slot_undershirt    "undershirt"
#define slot_underwear     "underwear"
#define slot_socks         "socks"

#define slot_in_backpack   "put_in_backpack"
#define slot_splints       "splints"
#define slot_bandages      "bandages"

#define SLOT_HANDS         list(slot_l_hand, slot_r_hand)
#define SLOT_POCKETS       list(slot_l_store, slot_r_store)
#define SLOT_HANDS_POCKETS list(SLOT_HANDS, SLOT_POCKETS)


//Sol translation for dog slots.
#define slot_mouth        slot_wear_mask  // 2
#define slot_neck         slot_handcuffed // 3
