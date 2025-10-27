/// A wrapper for [/atom/proc/ex_act] for tg compability, we can need it in the future for signals and contents_explosion
#define EX_ACT(target, args...)\
	target.ex_act(##args);

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = SS_INIT_EXPLOSIONS
	priority = SS_PRIORITY_EXPLOSIONS
	wait = SS_WAIT_EXPLOSION
	flags = SS_TICKER | SS_NO_INIT | SS_SHOW_IN_MC_TAB
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0
	var/cost_flameturf = 0

	var/cost_low_mov_atom = 0
	var/cost_med_mov_atom = 0
	var/cost_high_mov_atom = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()
	var/list/flameturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	var/currentpart = SSEXPLOSIONS_TURFS

	// cap, usual ratio ~1:2:3:3:3
	var/MAX_EX_DEVESTATION_RANGE = 3
	var/MAX_EX_HEAVY_RANGE = 7
	var/MAX_EX_LIGHT_RANGE = 14
	var/MAX_EX_FLASH_RANGE = 14
	var/MAX_EX_FLAME_RANGE = 14

/datum/controller/subsystem/explosions/stat_entry(msg)
	msg += "C:{"
	msg += "LT:[round(cost_lowturf, 1)]|"
	msg += "MT:[round(cost_medturf, 1)]|"
	msg += "HT:[round(cost_highturf, 1)]|"
	msg += "FT:[round(cost_flameturf, 1)]|"

	msg += "LO:[round(cost_low_mov_atom, 1)]|"
	msg += "MO:[round(cost_med_mov_atom, 1)]|"
	msg += "HO:[round(cost_high_mov_atom, 1)]|"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[lowturf.len]|"
	msg += "MT:[medturf.len]|"
	msg += "HT:[highturf.len]|"
	msg += "FT:[flameturf.len]||"

	msg += "LO:[low_mov_atom.len]|"
	msg += "MO:[med_mov_atom.len]|"
	msg += "HO:[high_mov_atom.len]|"

	msg += "} "
	return ..()

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || flameturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/**
 * Makes a given atom explode.
 *
 * Arguments:
 * - [epicenter][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 */
/proc/explosion(turf/epicenter, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flash_range = null, flame_range = null, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = TRUE, atom/explosion_cause = null)
	. = SSexplosions.explode(arglist(args))

/**
 * Makes a given turf explode. Now on the explosions subsystem!
 *
 * Arguments:
 * - [epicenter][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 */
/datum/controller/subsystem/explosions/proc/explode(turf/epicenter, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flash_range = null, flame_range = null, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = TRUE, atom/explosion_cause = null)

	SSStatistics.add_explosion_stat(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	propagate_blastwave(arglist(args))
	return

/**
 * Handles the effects of an explosion originating from a given point.
 *
 * Primarily handles popagating the balstwave of the explosion to the relevant turfs.
 * Also handles the fireball from the explosion.
 * Also handles the smoke cloud from the explosion.
 * Also handles sfx and screenshake.
 *
 * Arguments:
 * - [epicenter][/atom]: The location of the explosion rounded to the nearest turf.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to TRUE for some mysterious reason.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - explosion_cause: The atom that caused the explosion. Used for logging.
 */
/datum/controller/subsystem/explosions/proc/propagate_blastwave(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range, adminlog, ignorecap, silent, smoke, explosion_cause)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	if(isnull(flame_range))
		flame_range = light_impact_range
	if(isnull(flash_range))
		flash_range = devastation_range

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	if(!ignorecap)
		devastation_range = min(MAX_EX_DEVESTATION_RANGE , devastation_range)
		heavy_impact_range = min(MAX_EX_HEAVY_RANGE, heavy_impact_range)
		light_impact_range = min(MAX_EX_LIGHT_RANGE, light_impact_range)
		flash_range = min(MAX_EX_FLASH_RANGE, flash_range)
		flame_range = min(MAX_EX_FLAME_RANGE, flame_range)

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)

	if(adminlog)
		message_admins("Explosion with size (Devast: [devastation_range], Heavy: [heavy_impact_range], Light: [light_impact_range]) in area [epicenter.loc.name] ([COORD(epicenter)] - [ADMIN_JMP(epicenter)])")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name]")

	SEND_SIGNAL(src, COMSIG_EXPLOSIONS_EXPLODE, epicenter, devastation_range, heavy_impact_range, light_impact_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y

	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	// 3/7/14 will calculate to 80 + 35

	var/far_dist = 0
	far_dist += heavy_impact_range * 10
	far_dist += devastation_range * 20

	if(!silent)
		shake_the_room(epicenter, near_distance = orig_max_distance, far_distance = far_dist, quake_factor = devastation_range, echo_factor = heavy_impact_range)

	if(heavy_impact_range > 1)
		var/datum/effect/system/explosion/explosion_effect = new
		var/practicles_num = max(devastation_range * 2, heavy_impact_range)
		explosion_effect.set_up(epicenter, practicles_num)
		INVOKE_ASYNC(explosion_effect, TYPE_PROC_REF(/datum/effect/system/explosion, start))

		if(smoke)
			var/datum/effect/effect/system/smoke_spread/bad/smoke_effect = new
			var/smoke_num = max(devastation_range, round(sqrt(heavy_impact_range)))
			smoke_effect.set_up(smoke_num, 0, epicenter)
			addtimer(CALLBACK(smoke_effect, TYPE_PROC_REF(/datum/effect/effect/system/smoke_spread, start)), 5)

	if(flash_range)
		for(var/mob/living/Mob_to_flash in viewers(flash_range, epicenter))
			Mob_to_flash.flash_eyes()

	var/list/affected_turfs = prepare_explosion_turfs(max_range, epicenter)

	// this list is setup in the form position -> block for that position
	// we assert that turfs will be processed closed to farthest, so we can build this as we go along
	// This is gonna be an array, index'd by turfs
	var/list/cached_exp_block = list()

	//lists are guaranteed to contain at least 1 turf at this point
	//we presuppose that we'll be iterating away from the epicenter
	for(var/turf/explode as anything in affected_turfs)
		var/our_x = explode.x
		var/our_y = explode.y
		var/dist = HYPOTENUSE(our_x, our_y, x0, y0)

		// Using this pattern, block will flow out from blocking turfs, essentially caching the recursion
		// This is safe because if get_step_towards is ever anything but caridnally off, it'll do a diagonal move
		// So we always sample from a "loop" closer
		// It's kind of behaviorly unimpressive that that's a problem for the future
		if(config.reactionary_explosions)
			// resistance actually just "pushing" turf from explosion range
			var/resistance = explode.explosive_resistance // should we use armor instead?
			for(var/atom/A in explode) // tg has a way to optimize it, but it's soo tg so i don't want to port it
				if(A.explosive_resistance)
					resistance += A.explosive_resistance

			if(explode == epicenter)
				cached_exp_block[explode] = resistance / 4 // inner explosion - resistance less effective
			else
				var/our_block = cached_exp_block[get_step_towards(explode, epicenter)]
				dist += our_block + resistance / 2 // use half of own resistance, full resistance for turfs behind
				cached_exp_block[explode] = our_block + resistance

		var/severity = EXPLODE_NONE
		if(dist < devastation_range)
			severity = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			severity = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			severity = EXPLODE_LIGHT

		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += explode
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += explode
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += explode

		if(prob(40) && dist < flame_range && !isspaceturf(explode) && !explode.density)
			flameturf += explode

// Explosion SFX defines...
/// The probability that a quaking explosion will make the station creak per unit. Maths!
#define QUAKE_CREAK_PROB 30
/// The probability that an echoing explosion will make the station creak per unit.
#define ECHO_CREAK_PROB 5
/// Time taken for the hull to begin to creak after an explosion, if applicable.
#define CREAK_DELAY (5 SECONDS)
/// Lower limit for far explosion SFX volume.
#define FAR_LOWER 40
/// Upper limit for far explosion SFX volume.
#define FAR_UPPER 60
/// The probability that a distant explosion SFX will be a far explosion sound rather than an echo. (0-100)
#define FAR_SOUND_PROB 75
/// The upper limit on screenshake amplitude for nearby explosions.
#define NEAR_SHAKE_CAP 5
/// The upper limit on screenshake amplifude for distant explosions.
#define FAR_SHAKE_CAP 1.5
/// The duration of the screenshake for nearby explosions.
#define NEAR_SHAKE_DURATION (1.5 SECONDS)
/// The duration of the screenshake for distant explosions.
#define FAR_SHAKE_DURATION (1 SECONDS)
/// The lower limit for the randomly selected hull creaking volume.
#define CREAK_LOWER_VOL 55
/// The upper limit for the randomly selected hull creaking volume.
#define CREAK_UPPER_VOL 70

/**
 * Handles the sfx and screenshake caused by an explosion.
 *
 * Arguments:
 * - [epicenter][/turf]: The location of the explosion.
 * - near_distance: How close to the explosion you need to be to get the full effect of the explosion.
 * - far_distance: How close to the explosion you need to be to hear more than echos.
 * - quake_factor: Main scaling factor for screenshake.
 * - echo_factor: Whether to make the explosion echo off of very distant parts of the station.
 * - creaking: Whether to make the station creak. Autoset if null.
 * - [near_sound][/sound]: The sound that plays if you are close to the explosion.
 * - [far_sound][/sound]: The sound that plays if you are far from the explosion.
 * - [echo_sound][/sound]: The sound that plays as echos for the explosion.
 * - [creaking_sound][/sound]: The sound that plays when the station creaks during the explosion.
 * - [hull_creaking_sound][/sound]: The sound that plays when the station creaks after the explosion.
 */
/datum/controller/subsystem/explosions/proc/shake_the_room(turf/epicenter, near_distance, far_distance, quake_factor, echo_factor, creaking, near_sound = pick(SOUNDIN_EXPLOSION), far_sound = pick(SOUNDIN_EXPLOSION_FAR), echo_sound = pick(SOUNDIN_EXPLOSION_ECHO), creaking_sound = pick(SOUNDIN_EXPLOSION_CREAK), hull_creaking_sound = pick(SOUNDIN_CREAK))
	var/blast_z = epicenter.z
	if(isnull(creaking)) // Autoset creaking.
		var/on_station = SSmapping.level_trait(epicenter.z, ZTRAIT_STATION)
		if(on_station && prob((quake_factor * QUAKE_CREAK_PROB) + (echo_factor * ECHO_CREAK_PROB))) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
			creaking = TRUE // prob over 100 always returns true
		else
			creaking = FALSE

	for(var/mob/listener as anything in global.player_list)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || listener_turf.z != blast_z)
			continue

		var/distance = get_dist(epicenter, listener_turf)
		if(epicenter == listener_turf)
			distance = 0
		var/base_shake_amount = sqrt(near_distance / (distance + 1))
		if(distance <= round(near_distance + world.view - 2, 1)) // If you are close enough to see the effects of the explosion first-hand (ignoring walls)
			listener.playsound_local(epicenter, near_sound, VOL_EFFECTS_MASTER, vol = 100, vary = TRUE)
			if(base_shake_amount > 0)
				shake_camera(listener, NEAR_SHAKE_DURATION, clamp(base_shake_amount, 0, NEAR_SHAKE_CAP))

		else if(distance < far_distance) // You can hear a far explosion if you are outside the blast radius. Small explosions shouldn't be heard throughout the station.
			var/far_volume = clamp(far_distance / 2, FAR_LOWER, FAR_UPPER)
			if(creaking)
				listener.playsound_local(epicenter, creaking_sound, VOL_EFFECTS_MASTER, vol = far_volume, vary = TRUE, voluminosity = FALSE, distance_multiplier = 0)
			else if(prob(FAR_SOUND_PROB)) // Sound variety during meteor storm/tesloose/other bad event
				listener.playsound_local(epicenter, far_sound, VOL_EFFECTS_MASTER, vol = far_volume, vary = TRUE, voluminosity = FALSE, distance_multiplier = 0)
			else
				listener.playsound_local(epicenter, echo_sound, VOL_EFFECTS_MASTER, vol = far_volume, vary = TRUE, voluminosity = FALSE, distance_multiplier = 0)

			if(base_shake_amount || quake_factor)
				base_shake_amount = max(base_shake_amount, quake_factor * 3, 0) // Devastating explosions rock the station and ground
				shake_camera(listener, FAR_SHAKE_DURATION, min(base_shake_amount, FAR_SHAKE_CAP))

		else if(!isspaceturf(listener_turf) && echo_factor) // Big enough explosions echo through the hull.
			var/echo_volume
			if(quake_factor)
				echo_volume = 60
				shake_camera(listener, FAR_SHAKE_DURATION, clamp(quake_factor / 4, 0, FAR_SHAKE_CAP))
			else
				echo_volume = 40
			listener.playsound_local(epicenter, echo_sound, VOL_EFFECTS_MASTER, vol = echo_volume, vary = TRUE, distance_multiplier = 0)

		if(creaking) // 5 seconds after the bang (~duration of SOUNDIN_EXPLOSION_CREAK), the station begins to creak
			listener.playsound_local_timed(CREAK_DELAY, epicenter, hull_creaking_sound, volume_channel = VOL_EFFECTS_MASTER, vol = rand(CREAK_LOWER_VOL, CREAK_UPPER_VOL), vary = TRUE, voluminosity = FALSE, distance_multiplier = 0)

#undef CREAK_DELAY
#undef QUAKE_CREAK_PROB
#undef ECHO_CREAK_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef FAR_SOUND_PROB
#undef NEAR_SHAKE_CAP
#undef FAR_SHAKE_CAP
#undef NEAR_SHAKE_DURATION
#undef FAR_SHAKE_DURATION
#undef CREAK_LOWER_VOL
#undef CREAK_UPPER_VOL

/// Returns a list of turfs in X range from the epicenter
/// Returns in a unique order, spiraling outwards
/// This is done to ensure our progressive cache of blast resistance is always valid
/// This is quite fast
/proc/prepare_explosion_turfs(range, turf/epicenter)
	var/list/outlist = list()
	// Add in the center
	outlist += epicenter

	var/our_x = epicenter.x
	var/our_y = epicenter.y
	var/our_z = epicenter.z

	var/max_x = world.maxx
	var/max_y = world.maxy
	for(var/i in 1 to range)
		var/lowest_x = our_x - i
		var/lowest_y = our_y - i
		var/highest_x = our_x + i
		var/highest_y = our_y + i
		// top left to one before top right
		if(highest_y <= max_y)
			outlist += block(
				locate(max(lowest_x, 1), highest_y, our_z),
				locate(min(highest_x - 1, max_x), highest_y, our_z))
		// top right to one before bottom right
		if(highest_x <= max_x)
			outlist += block(
				locate(highest_x, min(highest_y, max_y), our_z),
				locate(highest_x, max(lowest_y + 1, 1), our_z))
		// bottom right to one before bottom left
		if(lowest_y >= 1)
			outlist += block(
				locate(min(highest_x, max_x), lowest_y, our_z),
				locate(max(lowest_x + 1, 1), lowest_y, our_z))
		// bottom left to one before top left
		if(lowest_x >= 1)
			outlist += block(
				locate(lowest_x, max(lowest_y, 1), our_z),
				locate(lowest_x, min(highest_y - 1, max_y), our_z))

	return outlist

/datum/controller/subsystem/explosions/fire(resumed = 0)
	if(!is_exploding())
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE_REAL
		var/list/low_turf = lowturf
		lowturf = list()
		for(var/turf/turf_thing as anything in low_turf)
			EX_ACT(turf_thing, EXPLODE_LIGHT)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medturf
		medturf = list()
		for(var/turf/turf_thing as anything in med_turf)
			EX_ACT(turf_thing, EXPLODE_HEAVY)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highturf
		highturf = list()
		for(var/turf/turf_thing as anything in high_turf)
			EX_ACT(turf_thing, EXPLODE_DEVASTATE)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/flame_turf = flameturf
		flameturf = list()
		for(var/turf/turf_thing as anything in flame_turf)
			//Mostly for ambience!
			new /obj/effect/firewave(turf_thing)
		cost_flameturf = MC_AVERAGE(cost_flameturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		if(low_turf.len || med_turf.len || high_turf.len)
			Master.laggy_byond_map_update_incoming()

	if(currentpart == SSEXPLOSIONS_MOVABLES)

		timer = TICK_USAGE_REAL
		var/list/local_high_mov_atom = high_mov_atom
		high_mov_atom = list()
		//todo: maybe check for atom.simulated and ABSTRACT flag, currently it calls ex_act for lighting
		for(var/atom/movable/movable_thing as anything in local_high_mov_atom)
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_DEVASTATE)
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/atom/movable/movable_thing as anything in local_med_mov_atom)
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_HEAVY)
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/atom/movable/movable_thing as anything in local_low_mov_atom)
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_LIGHT)
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	currentpart = SSEXPLOSIONS_TURFS
