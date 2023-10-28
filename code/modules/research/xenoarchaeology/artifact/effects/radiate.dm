/datum/artifact_effect/radiate
	log_name = "Radiate"
	var/radiation_amount

/datum/artifact_effect/radiate/New()
	..()
	radiation_amount = rand(1, 10)
	type_name = pick(ARTIFACT_EFFECT_PARTICLE, ARTIFACT_EFFECT_ORGANIC)

/datum/artifact_effect/radiate/DoEffectTouch(mob/living/user)
	. = ..()
	if(!.)
		return
	irradiate_one_mob(user, radiation_amount * 5)
	user.updatehealth()

/datum/artifact_effect/radiate/DoEffectAura()
	. = ..()
	if(!.)
		return
	irradiate_one_mob(holder, radiation_amount)

/datum/artifact_effect/radiate/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	irradiate_one_mob(holder, radiation_amount * used_power)
