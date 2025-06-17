#define DEBUG					//Enables byond profiling and full runtime logs - note, this may also be defined in your .dme file
								//Enables in-depth debug messages to runtime log (used for debugging)
//#define TESTING				//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)
//#define EARLY_PROFILE  // uncomment to automatically start profiler at the world init, not waiting
                         // for the subsystems initialization. Allows to collect data for the early init phase

/***** All toggles for the GC ref finder *****/

// #define REFERENCE_TRACKING		// Uncomment to enable ref finding

// #define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.

// #define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping

/***** End toggles for the GC ref finder *****/

#define BACKGROUND_ENABLED 0    // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.
								// 1 will enable set background. 0 will disable set background.

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 516
#if DM_VERSION < MIN_COMPILER_VERSION && !defined(SPACEMAN_DMM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 516 or higher
#endif

#define RECOMMENDED_VERSION 516
