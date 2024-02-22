/datum/space_level
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
	set_level_light(new /datum/level_lighting_effect/starlight) // todo: config

	SSenvironment.update(z_value, envtype)

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

/*	if(!effect.transition_delay)
		color_holder.color = effect.
		return*/

	var/previous_color = color_holder.color

	// stop any current animation first
	animate(color_holder, time = 0, color = previous_color, flags = ANIMATION_CONTINUE)

	for(var/effect_color in effect.colors)
		animate(color_holder, time = effect.transition_delay, color = effect_color, flags = ANIMATION_CONTINUE)

	if(effect.reset_after)
		animate(color_holder, time = effect.transition_delay, color = previous_color, flags = ANIMATION_CONTINUE)
