/// A wrapper for [/atom/proc/ex_act] to ensure that the explosion propagation and attendant signal are always handled.
#define EX_ACT(target, args...)\
	target.ex_act(##args);

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = SS_INIT_EXPLOSIONS
	priority = SS_PRIORITY_EXPLOSIONS
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0

	var/cost_low_mov_atom = 0
	var/cost_med_mov_atom = 0
	var/cost_high_mov_atom = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	// Track how many explosions have happened.
	var/explosion_index = 0

	var/currentpart = SSAIR_PIPENETS

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/datum/controller/subsystem/explosions/fire(resumed = 0)
	if (!is_exploding())
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE_REAL
		var/list/low_turf = lowturf
		lowturf = list()
		for(var/thing in low_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_LIGHT)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medturf
		medturf = list()
		for(var/thing in med_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_HEAVY)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highturf
		highturf = list()
		for(var/thing in high_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_DEVASTATE)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL

	if(currentpart == SSEXPLOSIONS_MOVABLES)

		timer = TICK_USAGE_REAL
		var/list/local_high_mov_atom = high_mov_atom
		high_mov_atom = list()
		for(var/thing in local_high_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_DEVASTATE)
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/thing in local_med_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_HEAVY)
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/thing in local_low_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_LIGHT)
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	currentpart = SSEXPLOSIONS_TURFS
