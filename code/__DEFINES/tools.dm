// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20

//Tool types defines

#define QUALITY_CUTTING       "cutting"          // for wirecutters/knifes/jaws of life
#define QUALITY_PRYING        "prying"           // for crowbar/jaws of life
#define QUALITY_WRENCHING     "wrenching"        // for wrench/hand drill
#define QUALITY_SCREWING      "screwing"         // for screwdriver/hand drill
#define QUALITY_WELDING       "welding"          // for welding tools
#define QUALITY_PULSING       "pulsing"          // for multitools
#define QUALITY_SIGNALLING    "signaling"        // for signaller
#define QUALITY_ROCK_DRILL    "rock_drill"       // for massive drills

// Special IPC surgery

#define QUALITY_MENDING_IPC           "mending_IPC"      // for nanopaste/bongel/wrench

#define QUALITY_SURGERY_CUTTING       "surgery_cutting"  // for scalples and cutting items
#define QUALITY_SURGERY_CLAMP         "clamp"            // like hemostat/cutters
#define QUALITY_SURGERY_RETRACT       "retract"          // like retractor/screwdriver/fork
#define QUALITY_SURGERY_SAW           "surgery_saw"      // like circut_saw/crowbar
#define QUALITY_SURGERY_DRILL         "surgery_drill"    // like surgical_drill/pen
#define QUALITY_SURGERY_BONESET       "bone_set"         // like bonesetter/wrench
#define QUALITY_SURGERY_MENDINGBONE   "mending"          // like bone_gel/rods/alien_bone_gel
#define QUALITY_SURGERY_FIXVEIN       "fix_vein"         // like fix_ovein/cable
#define QUALITY_SURGERY_CAUTER        "cauter"           // like cautery/welding_tool
#define QUALITY_SURGERY_DROP_LIQUID   "drop_liquid"      // for reaget_containers

#define QUALITY_SURGERY_OPERATE_TABLE "operate_table"    // for surgery tables

