// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20

//Tool types defines

#define QUALITY_CUTTING  "cutting"	// for wirecutters/knifes/jaws of life
#define QUALITY_PRYING   "prying"	// for crowbar/jaws of life
#define QUALITY_WRENCH	 "wrench"	// for wrench/hand drill
#define QUALITY_SCREWING "screwing"	// for screwdriver/hand drill
#define QUALITY_WELDING  "welding"	// for welding tools

#define QUALITY_PULSE	 "pulse"	// for multitools

#define QUALITY_SIGNAL	 "signal"	// for signaller
