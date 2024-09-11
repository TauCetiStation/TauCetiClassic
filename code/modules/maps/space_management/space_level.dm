/datum/space_level // not only space, bad naming
	var/name = "NAME MISSING"
	var/list/traits
	var/z_value = 1 //actual z placement
	var/linkage = UNAFFECTED
	var/envtype = ENV_TYPE_SPACE // use SSenvironment.envtype[z_value] instead

	// this effect is shared between all clients on z-level
	var/obj/effect/level_color_holder/color_holder

/datum/space_level/New(new_z, new_name, list/new_traits = list())
	z_value = new_z
	name = new_name
	traits = new_traits
	linkage = new_traits[ZTRAIT_LINKAGE]
	envtype = new_traits[ZTRAIT_ENV_TYPE] || envtype

	color_holder = new()

	// any better place for this?
	// todo: add map config
	var/level_lighting_type
	if(ZTRAIT_CENTCOM in traits)
		level_lighting_type = /datum/level_lighting_effect/centcomm
	else if(envtype == ENV_TYPE_SNOW)
		level_lighting_type = /datum/level_lighting_effect/snow_map_random
	else if(envtype == ZTRAIT_JUNKYARD)
		level_lighting_type = /datum/level_lighting_effect/junkyard
	else
		level_lighting_type = /datum/level_lighting_effect/starlight

	set_level_light(new level_lighting_type)

	SSenvironment.update(z_value, envtype)

// can accept hex color or /datum/level_lighting_effect object
/datum/space_level/proc/set_level_light(color)
	if(color_holder.locked)
		return

	if(istext(color))
		color_holder.color = color
		return

	if(!istype(color, /datum/level_lighting_effect))
		return

	var/datum/level_lighting_effect/effect = color

	if(effect.lock_after)
		color_holder.locked = TRUE

	var/previous_color = color_holder.color

	// stop any current animation first
	animate(color_holder, time = 0, color = previous_color, flags = ANIMATION_END_NOW)

	for(var/effect_color in effect.colors)
		animate(color_holder, time = effect.transition_delay, color = effect_color, flags = ANIMATION_CONTINUE)

	if(effect.reset_after)
		animate(color_holder, time = effect.transition_delay, color = previous_color, flags = ANIMATION_CONTINUE)
