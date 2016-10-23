// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/top_atom       // The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/source_atom    // The atom that we belong to.

	var/turf/source_turf    // The turf under the above.
	var/light_power         // Intensity of the emitter light.
	var/light_range         // The range of the emitted light.
	var/light_color         // The colour of the light, string, decomposed by parse_light_color()

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	var/list/datum/lighting_corner/effect_str     // List used to store how much we're affecting corners.
	var/list/turf/affecting_turfs

	var/applied             // Whether we have applied our light yet or not.

	var/vis_update          // Whether we should smartly recalculate visibility. and then only update tiles that became (in)visible to us.
	var/needs_update        // Whether we are queued for an update.
	var/destroyed           // Whether we are destroyed and need to stop emitting light.
	var/force_update

/datum/light_source/New(var/atom/owner, var/atom/top)
	source_atom = owner // Set our new owner.
	if(!source_atom.light_sources)
		source_atom.light_sources = list()

	source_atom.light_sources += src // Add us to the lights of our owner.
	top_atom = top
	if(top_atom != source_atom)
		if(!top.light_sources)
			top.light_sources     = list()

		top_atom.light_sources += src

	source_turf = top_atom
	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	parse_light_color()

	effect_str      = list()
	affecting_turfs = list()

	update()

	return ..()

// Kill ourselves.
/datum/light_source/proc/destroy()
	destroyed = 1
	force_update()
	if(source_atom && source_atom.light_sources)
		source_atom.light_sources -= src
		source_atom                = null

	if(top_atom && top_atom.light_sources)
		top_atom.light_sources    -= src
		top_atom                   = null

// Call it dirty, I don't care.
// This is here so there's no performance loss on non-instant updates from the fact that the engine can also do instant updates.
// If you're wondering what's with the "BYOND" argument: BYOND won't let me have a () macro that has no arguments :|.
#define effect_update(BYOND)               \
	if(!needs_update)                      \
	{                                      \
		SSlighting.changed_lights += src;  \
		needs_update            = TRUE;    \
	}

// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/light_source/proc/update(atom/new_top_atom)
	// This top atom is different.
	if(new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom) // Remove ourselves from the light sources of that top atom.
			top_atom.light_sources -= src

		top_atom = new_top_atom

		if(top_atom != source_atom)
			if(!top_atom.light_sources)
				top_atom.light_sources = list()

			top_atom.light_sources += src // Add ourselves to the light sources of our new top atom.

	effect_update(null)

// Will force an update without checking if it's actually needed.
/datum/light_source/proc/force_update()
	force_update = 1

	effect_update(null)

// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/light_source/proc/vis_update()
	vis_update = 1

	effect_update(null)

// Will check if we actually need to update, and update any variables that may need to be updated.
/datum/light_source/proc/check()
	if(!source_atom || !light_range || !light_power)
		destroy()
		return 1

	if(!top_atom)
		top_atom = source_atom
		. = 1

	if(istype(top_atom, /turf))
		if(source_turf != top_atom)
			source_turf = top_atom
			. = 1
	else if(top_atom.loc != source_turf)
		source_turf = top_atom.loc
		. = 1

	if(source_atom.light_power != light_power)
		light_power = source_atom.light_power
		. = 1

	if(source_atom.light_range != light_range)
		light_range = source_atom.light_range
		. = 1

	if(light_range && light_power && !applied)
		. = 1

	if(source_atom.light_color != light_color)
		light_color = source_atom.light_color
		parse_light_color()
		. = 1

// Decompile the hexadecimal colour into lumcounts of each perspective.
/datum/light_source/proc/parse_light_color()
	if(light_color)
		lum_r = GetRedPart   (light_color) / 255
		lum_g = GetGreenPart (light_color) / 255
		lum_b = GetBluePart  (light_color) / 255
	else
		lum_r = 1
		lum_g = 1
		lum_b = 1

// Macro that applies light to a new corner.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.

#define APPLY_CORNER(C)              \
	. = LUM_FALLOFF(C, source_turf); \
                                     \
	. *= light_power;                \
                                     \
	effect_str[C] = .;               \
                                     \
	C.update_lumcount                \
	(                                \
		. * applied_lum_r,           \
		. * applied_lum_g,           \
		. * applied_lum_b            \
	);

// I don't need to explain what this does, do I?
#define REMOVE_CORNER(C)             \
	. = -effect_str[C];              \
	C.update_lumcount                \
	(                                \
		. * applied_lum_r,           \
		. * applied_lum_g,           \
		. * applied_lum_b            \
	);

// This is the define used to calculate falloff.
#define LUM_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 + LIGHTING_HEIGHT) / max(1, light_range)))

/datum/light_source/proc/apply_lum()
	applied = 1

	// Keep track of the last applied lum values so that the lighting can be reversed
	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	if(istype(source_turf))
		FOR_DVIEW(var/turf/T, light_range, source_turf, INVISIBILITY_LIGHTING)
			for(var/A in T.get_corners(get_dir(source_turf, T)))
				if(!A)
					continue

				var/datum/lighting_corner/C = A
				if(effect_str.Find(C))
					continue

				if(!C.active)
					continue

				C.affecting += src
				APPLY_CORNER(C)

			if(!T.affecting_lights)
				T.affecting_lights = list()

			if(T.corners[1])
				var/datum/lighting_corner/C = T.corners[1]
				if(!C.active)
					END_FOR_DVIEW
					return

			T.affecting_lights += src
			affecting_turfs += T
		END_FOR_DVIEW

/datum/light_source/proc/remove_lum()
	applied = FALSE

	for(var/A in affecting_turfs)
		if(!A)
			continue

		var/turf/T = A
		if(T.affecting_lights)
			T.affecting_lights -= src

	affecting_turfs.Cut()

	for(var/A in effect_str)
		if(!A)
			continue

		var/datum/lighting_corner/C = A
		REMOVE_CORNER(C)

		C.affecting -= src

	effect_str.Cut()

/datum/light_source/proc/recalc_corner(datum/lighting_corner/C)
	if(effect_str.Find(C)) // Already have one.
		REMOVE_CORNER(C)

	APPLY_CORNER(C)

/datum/light_source/proc/smart_vis_update()
	var/list/datum/lighting_corner/corners = list()
	FOR_DVIEW(var/turf/T, light_range, source_turf, 0)
		corners |= T.get_corners(get_dir(source_turf, T))
	END_FOR_DVIEW

	for(var/A in corners - effect_str) // New corners
		if(!A)
			continue

		var/datum/lighting_corner/C = A
		if(!C.active)
			continue

		if(C.masters[1])
			var/turf/T = C.masters[1]
			if(!T.affecting_lights)
				T.affecting_lights = list()
			T.affecting_lights += src

		C.affecting += src
		APPLY_CORNER(C)

	for(var/A in effect_str - corners) // Old, now gone, corners.
		if(!A)
			continue

		var/datum/lighting_corner/C = A
		if(!C.active)
			continue

		if(C.masters[1])
			var/turf/T = C.masters[1]
			if(T.affecting_lights)
				T.affecting_lights -= src

		C.affecting -= src
		REMOVE_CORNER(C)
		effect_str -= C

#undef effect_update
#undef LUM_FALLOFF
#undef REMOVE_CORNER
#undef APPLY_CORNER
