#define TICK_LIMIT_RUNNING 85  // Tick limit while running normally
#define TICK_LIMIT_TO_RUN 75   // Tick limit used to resume things in stoplag
#define TICK_LIMIT_MC 84       // Tick limit for MC while running
#define TICK_LIMIT_MC_INIT 100 // Tick limit while initializing

#define TICK_USAGE world.tick_usage //for general usage

#define TICK_CHECK ( world.tick_usage > CURRENT_TICKLIMIT ? stoplag() : 0 )
#define CHECK_TICK if (world.tick_usage > CURRENT_TICKLIMIT) stoplag()


#define TICKS *world.tick_lag

#define DS2TICKS(DS) (DS/world.tick_lag)

#define TICKS2DS(T) (T TICKS)
