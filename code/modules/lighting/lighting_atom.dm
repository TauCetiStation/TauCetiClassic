/atom
	// Light systems, both shouldn't be active at the same time.
	var/light_system = IMMOBILE_LIGHT
	// Intensity of the light. The stronger, the less shadows you will see on the lit area.
	var/light_power = 1
	// Range of the light in tiles. Zero means no light.
	var/light_range = 0
	// Hexadecimal RGB string representing the colour of the light. White by default.
	var/light_color = COLOR_WHITE
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = TRUE
	///Bitflags to determine lighting-related atom properties.
	var/light_flags = NONE

	// Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/datum/light_source/light
	// Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/tmp/list/light_sources

	///Lazylist to keep track on the sources of illumination.
	var/list/affected_dynamic_lights
	///Highest-intensity light affecting us, which determines our visibility.
	var/affecting_dynamic_lumi = 0

// The proc you should always use to set the light of this atom.
// Nonesensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE	//Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.

	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return

	if(!isnull(l_power))
		set_light_power(l_power)

	if(!isnull(l_range))
		set_light_range(l_range)

	if (l_color != NONSENSICAL_VALUE)
		set_light_color(l_color)

	update_light()

#undef NONSENSICAL_VALUE

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	set waitfor = FALSE
	if (QDELETED(src))
		return

	if(light_system != IMMOBILE_LIGHT)
		CRASH("update_light() for [src] with following light_system value: [light_system]")

	if (!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(light)
	else
		if (!ismovable(loc)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if (light) // Update the light or create it if it does not exist.
			light.update(.)
		else
			light = new/datum/light_source(src, .)

// Should always be used to change the opacity of an atom.
// It notifies (potentially) affected light sources so they can update (if needed).
/atom/proc/set_opacity(new_opacity)
	if (new_opacity == opacity)
		return

	opacity = new_opacity
	var/turf/T = loc
	if (!isturf(T))
		return

	if (new_opacity == TRUE)
		T.has_opaque_atom = TRUE
		T.reconsider_lights()
	else
		var/old_has_opaque_atom = T.has_opaque_atom
		T.recalc_atom_opacity()
		if (old_has_opaque_atom != T.has_opaque_atom)
			T.reconsider_lights()


/atom/movable/Moved(atom/OldLoc, Dir)
	. = ..()
	for (var/datum/light_source/light as anything in light_sources) // Cycle through the light sources on this atom and tell them to update.
		light.source_atom.update_light()

/atom/proc/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	return

/turf/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	if(!_duration)
		stack_trace("Lighting FX obj created on a turf without a duration")
	new /obj/effect/dummy/lighting_obj (src, _range, _power, _color, _duration)

/obj/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	if(!_duration)
		stack_trace("Lighting FX obj created on a obj without a duration")
	new /obj/effect/dummy/lighting_obj (get_turf(src), _range, _power, _color, _duration)

/mob/living/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	mob_light(_range, _power, _color, _duration)

/mob/living/proc/mob_light(_range, _power, _color, _duration)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = new (src, _range, _power, _color, _duration)
	return mob_light_obj

/// Setter for the light power of this atom.
/atom/proc/set_light_power(new_power)
	if(new_power == light_power)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_POWER, new_power) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_power
	light_power = new_power
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_POWER, .)

/// Setter for the light range of this atom.
/atom/proc/set_light_range(new_range)
	if(new_range == light_range)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_RANGE, new_range) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_range
	light_range = new_range
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_RANGE, .)

/// Setter for the light color of this atom.
/atom/proc/set_light_color(new_color)
	if(new_color == light_color)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_COLOR, new_color) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_color
	light_color = new_color
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_COLOR, .)

/// Setter for whether or not this atom's light is on.
/atom/proc/set_light_on(new_value)
	if(new_value == light_on)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_ON, new_value) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_on
	light_on = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_ON, .)

/// Setter for the light flags of this atom.
/atom/proc/set_light_flags(new_value)
	if(new_value == light_flags)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_FLAGS, new_value) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_flags
	light_flags = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_FLAGS, .)

///Keeps track of the sources of dynamic luminosity and updates our visibility with the highest.
/atom/movable/proc/update_dynamic_luminosity()
	var/highest = 0
	for(var/i in affected_dynamic_lights)
		if(affected_dynamic_lights[i] <= highest)
			continue
		highest = affected_dynamic_lights[i]
	if(highest == affecting_dynamic_lumi)
		return
	luminosity -= affecting_dynamic_lumi
	affecting_dynamic_lumi = highest
	luminosity += affecting_dynamic_lumi

/atom/movable/proc/turn_off_light_any_system()
	if(light_system == IMMOBILE_LIGHT)
		set_light(0)
	else
		set_light_on(FALSE)
