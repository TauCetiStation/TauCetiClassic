// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20

//Tool types defines

#define QUALITY_CUTTING    "cutting"	// for wirecutters/knifes/jaws of life
#define QUALITY_PRYING     "prying"		// for crowbar/jaws of life
#define QUALITY_WRENCHING  "wrenching"	// for wrench/hand drill
#define QUALITY_SCREWING   "screwing"	// for screwdriver/hand drill
#define QUALITY_WELDING    "welding"	// for welding tools

#define QUALITY_PULSING	    "pulsing"	// for multitools

#define QUALITY_SIGNALLING  "signaling"	// for signaller

#define QUALITY_ROCK_DRILL  "rock_drill" // for massive drills

#define QUALITY_DROP_LIQUID "drop_liquid" // for reaget_containers

#define QUALITY_OPERATE_TABLE "operate_table" // for surgery tables

#define QUALITY_SURGERY_TOOL"surgery_tool" 	// to check on /try_operate(), can this item operate
#define QUALITY_CLAMP		"clamp"			// like hemostat/cutters
#define QUALITY_RETRACT 	"retract"		// like retractor/screwdriver/fork
#define QUALITY_SAW_OPEN	"saw_open"		// like circut_saw/crowbar
#define QUALITY_DRILL_OPEN 	"drill_open"	// like surgical_drill/pen
#define QUALITY_BONE_SET	"bone_set"		// like bonesetter/wrench
#define QUALITY_FIX_BONE	"fix_bone"		// like bone_gel/rods/alien_bone_gel
#define QUALITY_FIX_VEIN	"fix_vein"		// like fix_ovein/cable
#define QUALITY_CAUTER		"cauter"		// like cautery/welding_tool
