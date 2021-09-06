/datum/artifact_effect/light
	log_name = "Light"

/datum/artifact_effect/light/New()
	..()
	release_method = ARTIFACT_EFFECT_TOUCH
	type_name= ARTIFACT_EFFECT_PARTICLE
	trigger = TRIGGER_TOUCH

/datum/artifact_effect/light/DoEffectTouch(mob/living/user)
	. = ..()
	if(!.)
		return
	switch_light(0.3 , 10)

/datum/artifact_effect/light/proc/switch_light(light_power, light_range)
	if(holder.light_power == initial(holder.light_power) && holder.light_range == initial(holder.light_range))
		holder.light_power = light_power
		holder.light_range = light_range
		return
	holder.light_power = initial(holder.light_power)
	holder.light_range = initial(holder.light_range)
    
/datum/artifact_effect/light/darkness
	log_name = "Darkness"

/datum/artifact_effect/light/darkness/DoEffectTouch(mob/living/user)
	switch_light(-3 , 8)
