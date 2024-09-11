// All of the possible Lag Switch lag mitigation measures
// If you add more do not forget to update MEASURES_AMOUNT accordingly

/// Stops ghosts flying around freely, they can still jump and orbit, staff exempted
#define DISABLE_DEAD_KEYLOOP 1

/// Stops ghosts using zoom verbs and resets their view if zoomed out, staff exempted
#define DISABLE_GHOST_ZOOM 2

/// Disable runechat and enable the bubbles, speaking mobs with TRAIT_BYPASS_MEASURES exempted
#define DISABLE_RUNECHAT 3

/// Disable bicon procs from verbs like examine, mobs calling with TRAIT_BYPASS_MEASURES exempted
#define DISABLE_BICON 4

/// Prevents anyone from joining the game as anything but observer
#define DISABLE_NON_OBSJOBS 5

/// Limit IC/dchat spam to one message every x seconds per client, TRAIT_BYPASS_MEASURES exempted
#define SLOWMODE_IC_CHAT 6

/// Disables parallax, as if everyone had disabled their preference, TRAIT_BYPASS_MEASURES exempted
#define DISABLE_PARALLAX 7

/// Disables footsteps, TRAIT_BYPASS_MEASURES exempted
#define DISABLE_FOOTSTEPS 8

#define MEASURES_AMOUNT 8 // The total number of switches defined above
