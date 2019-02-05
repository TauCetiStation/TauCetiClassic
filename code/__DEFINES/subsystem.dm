
#define INITIALIZATION_INSSATOMS     0   // New should not call atom_init
#define INITIALIZATION_INNEW_MAPLOAD 1   // New should call atom_init(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2   // New should call atom_init(FALSE)

#define INITIALIZE_HINT_NORMAL   0       // Nothing happens
#define INITIALIZE_HINT_LATELOAD 1       // Call atom_init_late
#define INITIALIZE_HINT_QDEL     2       // Call qdel on the atom

//type and all subtypes should always call atom_init in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
    ..();\
    if(!initialized) {\
        args[1] = TRUE;\
        SSatoms.InitAtom(src, args);\
    }\
}

// Subsystem init_order, from highest priority to lowest priority
// The numbers just define the ordering, they are meaningless otherwise.

#define SS_INIT_FLUIDS    10
#define SS_INIT_JOBS      9
#define SS_INIT_QUIRKS    8
#define SS_INIT_MAPPING   7
#define SS_INIT_XENOARCH  6
#define SS_INIT_ATOMS     5
#define SS_INIT_MACHINES  4
#define SS_INIT_SHUTTLES  3
#define SS_INIT_SUN       2
#define SS_INIT_LIGHTING  1
#define SS_INIT_DEFAULT   0
#define SS_INIT_AIR      -1
#define SS_INIT_ASSETS   -2


#define SS_PRIORITY_TICKER     200
#define SS_PRIORITY_NANOUI     110
#define SS_PRIORITY_MOBS       100
#define SS_PRIORITY_PARALAX    65
#define SS_PRIORITY_DEFAULT    50
#define SS_PRIORITY_OBJECTS    40
#define SS_PRIORITY_QUIRKS     40
#define SS_PRIORITY_ORBIT      35
#define SS_PRIORITY_SPACEDRIFT 30
#define SS_PRIORITY_THROWING   25
#define SS_PRIORITY_LIGHTING   25
#define SS_PRIORITY_AIR        20
#define SS_PRIORITY_FLUIDS     20
#define SS_PRIORITY_GARBAGE    15
#define SS_PRIORITY_SUN        3


#define SS_WAIT_THROWING   1
#define SS_WAIT_TIMER      1
#define SS_WAIT_LIGHTING   1
#define SS_WAIT_PARALAX    2
#define SS_WAIT_ORBIT      2
#define SS_WAIT_FLUIDS     3
#define SS_WAIT_GARBAGE    5
#define SS_WAIT_SPACEDRIFT 5
#define SS_WAIT_NANOUI     10
#define SS_WAIT_SHUTTLES   10
#define SS_WAIT_VOTE       10
#define SS_WAIT_AIR        10
#define SS_WAIT_QUIRKS     10
#define SS_WAIT_DEFAULT    20
#define SS_WAIT_SUN        600


#define SS_DISPLAY_AIR      1
#define SS_DISPLAY_FLUIDS   2
#define SS_DISPLAY_GARBAGE  3
#define SS_DISPLAY_MACHINES 4
#define SS_DISPLAY_MOBS     5
#define SS_DISPLAY_LIGHTING 6
#define SS_DISPLAY_TIMER    7
#define SS_DISPLAY_NANOUI   8
#define SS_DISPLAY_DEFAULT  100
