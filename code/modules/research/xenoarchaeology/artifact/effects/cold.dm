
/datum/artifact_effect/temperature
	var/target_temp
	var/target_temp_low
	var/target_temp_high

/datum/artifact_effect/temperature/New()
	..()
	target_temp = rand(target_temp_low, target_temp_high)
	effect = pick(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	effect_type = pick(ARTIFACT_EFFECT_ORGANIC, ARTIFACT_EFFECT_BLUESPACE, ARTIFACT_EFFECT_SYNTH)

/datum/artifact_effect/temperature/DoEffectTouch(mob/user)
	if(!user)
		return FALSE
	var/datum/gas_mixture/env = holder.loc.return_air()
	if(!env)
		return FALSE
	return env


/datum/artifact_effect/temperature/DoEffectAura()
	if(!holder)
		return FALSE
	var/datum/gas_mixture/env = holder.loc.return_air()
	if(!env)
		return FALSE
	return env

/datum/artifact_effect/temperature/cold
	effect_name = "Cold"
	target_temp_low = 40
	target_temp_high = 180

/datum/artifact_effect/temperature/cold/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	var/datum/gas_mixture/env = .
	env.temperature = clamp(env.temperature - 25, target_temp_low, target_temp_high)
	to_chat(user, "<span class='notice'>A chill passes up your spine!</span>")

/datum/artifact_effect/temperature/cold/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/datum/gas_mixture/env = .
	if(env.temperature > target_temp)
		env.temperature -= pick(0, 0, 1)

/datum/artifact_effect/temperature/heat
	effect_name = "Heat"
	target_temp_low = 300
	target_temp_high = 600

/datum/artifact_effect/temperature/heat/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	var/datum/gas_mixture/env = .
	env.temperature = clamp(env.temperature + 25, target_temp_low, target_temp_high)
	to_chat(user, "<span class='warning'>You feel a wave of heat travel up your spine!</span>")

/datum/artifact_effect/temperature/heat/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/datum/gas_mixture/env = .
	if(env.temperature > target_temp)
		env.temperature += pick(0, 0, 1)
