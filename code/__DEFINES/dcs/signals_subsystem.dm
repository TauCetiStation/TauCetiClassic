// Subsystem signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///Subsystem signals
///From base of datum/controller/subsystem/Initialize
// todo
//#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

///Called when the ticker enters the pre-game phase
#define COMSIG_TICKER_ENTER_PREGAME "comsig_ticker_enter_pregame"

///Called when the ticker sets up the game for start
#define COMSIG_TICKER_ENTER_SETTING_UP "comsig_ticker_enter_setting_up"

///Called when the ticker fails to set up the game for start
#define COMSIG_TICKER_ERROR_SETTING_UP "comsig_ticker_error_setting_up"

/// Called when the round has started, but before GAME_STATE_PLAYING.
#define COMSIG_TICKER_ROUND_STARTING "comsig_ticker_round_starting"

/// SSexplosions from base of /datum/controller/subsystem/explosions/proc/propagate_blastwave: (turf/epicenter, devastation_range, heavy_impact_range, light_impact_range)
#define COMSIG_EXPLOSIONS_EXPLODE "comsig_explosions_explode"

/// SSexplosions from base of /proc/empulse: (turf/epicenter, heavy_range, light_range)
#define COMSIG_EXPLOSIONS_EMPULSE "comsig_explosions_empulse" // empulse not part of subsystem, signal moved here for consistency with explosions

///From base of /datum/controller/subsystem/holomaps/proc/regenerate_custom_holomap: (holomap_key)
#define COMSIG_HOLOMAP_REGENERATED "comsig_holomap_regenerated"
