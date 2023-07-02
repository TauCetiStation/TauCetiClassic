#define MC_TICK_CHECK ( ( TICK_USAGE > Master.current_ticklimit || src.state != SS_RUNNING ) ? pause() : 0 )

#define MC_SPLIT_TICK_INIT(phase_count) var/original_tick_limit = Master.current_ticklimit; var/split_tick_phases = ##phase_count
#define MC_SPLIT_TICK \
    if(split_tick_phases > 1){\
        Master.current_ticklimit = ((original_tick_limit - TICK_USAGE) / split_tick_phases) + TICK_USAGE;\
        --split_tick_phases;\
    } else {\
        Master.current_ticklimit = original_tick_limit;\
    }


// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))
#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define MC_AVG_FAST_UP_SLOW_DOWN(average, current) (average > current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))
#define MC_AVG_SLOW_UP_FAST_DOWN(average, current) (average < current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))

#define START_PROCESSING_NAMED(Processor, Datum, Varname) if (!Datum.isprocessing) {Datum.isprocessing = 1;Processor.##Varname += Datum}
#define STOP_PROCESSING_NAMED(Processor, Datum, Varname) Datum.isprocessing = 0;Processor.##Varname -= Datum

#define START_PROCESSING(Processor, Datum) START_PROCESSING_NAMED(Processor, Datum, processing)
#define STOP_PROCESSING(Processor, Datum) STOP_PROCESSING_NAMED(Processor, Datum, processing)

//! SubSystem flags (Please design any new flags so that the default is off, to make adding flags to subsystems easier)

/// subsystem does not initialize.
#define SS_NO_INIT 1

/** subsystem does not fire. */
/// (like can_fire = 0, but keeps it from getting added to the processing subsystems list)
/// (Requires a MC restart to change)
#define SS_NO_FIRE 2

/** Subsystem only runs on spare cpu (after all non-background subsystems have ran that tick) */
/// SS_BACKGROUND has its own priority bracket, this overrides SS_TICKER's priority bump
#define SS_BACKGROUND 4

/** Treat wait as a tick count, not DS, run every wait ticks. */
/// (also forces it to run first in the tick (unless SS_BACKGROUND))
/// (implies all runlevels because of how it works)
/// This is designed for basically anything that works as a mini-mc (like SStimer)
#define SS_TICKER 8

/** keep the subsystem's timing on point by firing early if it fired late last fire because of lag */
/// ie: if a 20ds subsystem fires say 5 ds late due to lag or what not, its next fire would be in 15ds, not 20ds.
#define SS_KEEP_TIMING 16

/** Calculate its next fire after its fired. */
/// (IE: if a 5ds wait SS takes 2ds to run, its next fire should be 5ds away, not 3ds like it normally would be)
/// This flag overrides SS_KEEP_TIMING
#define SS_POST_FIRE_TIMING 32

// temporary for MC tab cleaning, we need https://github.com/TauCetiStation/TauCetiClassic/pull/7601 asap
#define SS_SHOW_IN_MC_TAB 64

//SUBSYSTEM STATES
#define SS_IDLE     0  // Aint doing shit.
#define SS_QUEUED   1  // Queued to run.
#define SS_RUNNING  2  // Actively running.
#define SS_PAUSED   3  // Paused by mc_tick_check.
#define SS_SLEEPING 4  // `fire()` slept.
#define SS_PAUSING  5  // In the middle of pausing.

#define SUBSYSTEM_DEF(X) var/datum/controller/subsystem/##X/SS##X;\
/datum/controller/subsystem/##X/New(){\
    NEW_SS_GLOBAL(SS##X);\
    PreInit();\
}\
/datum/controller/subsystem/##X

#define PROCESSING_SUBSYSTEM_DEF(X) var/datum/controller/subsystem/processing/##X/SS##X;\
/datum/controller/subsystem/processing/##X/New(){\
    NEW_SS_GLOBAL(SS##X);\
    PreInit();\
}\
/datum/controller/subsystem/processing/##X

#define TIMER_SUBSYSTEM_DEF(X) var/datum/controller/subsystem/timer/##X/SS##X;\
/datum/controller/subsystem/timer/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/timer/##X

// Timing subsystem
// Don't run if there is an identical unique timer active
#define TIMER_UNIQUE      (1<<0)
// For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE    (1<<1)
// Timing should be based on how timing progresses on clients, not the sever.
//  tracking this is more expensive,
//  should only be used in conjuction with things that have to progress client side, such as animate() or sound()
#define TIMER_CLIENT_TIME (1<<2)
// Timer can be stopped using deltimer()
#define TIMER_STOPPABLE   (1<<3)
///prevents distinguishing identical timers with the wait variable
///
///To be used with TIMER_UNIQUE
#define TIMER_NO_HASH_WAIT (1<<4)
