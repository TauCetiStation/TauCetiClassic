/datum/artifact_effect/light
	log_name = "Light"
	type_name = ARTIFACT_EFFECT_PARTICLE

/datum/artifact_effect/light/New()
	..()
	release_method = ARTIFACT_EFFECT_TOUCH
	trigger = TRIGGER_TOUCH
	activation_touch_cost = 0

/datum/artifact_effect/light/DoEffectTouch(mob/living/user)
	. = ..()
	if(!.)
		return
	switch_light(0.3 , 10)

/datum/artifact_effect/light/proc/switch_light(light_power, light_range)
	if(holder.light_power == initial(holder.light_power) && holder.light_range == initial(holder.light_range))
		holder.light_power = light_power
		holder.light_range = light_range
		holder.update_light()
		return
	holder.light_power = initial(holder.light_power)
	holder.light_range = initial(holder.light_range)
	holder.update_light()

/datum/artifact_effect/light/darkness
	log_name = "Darkness"

/datum/artifact_effect/light/darkness/DoEffectTouch(mob/living/user)
	switch_light(-4 , 8)
