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
	irradiate_in_dist(get_turf(user), radiation_amount * 5, 0)
	user.updatehealth()

/datum/artifact_effect/radiate/DoEffectAura()
	. = ..()
	if(!.)
		return
	irradiate_in_dist(get_turf(holder), radiation_amount, range)

/datum/artifact_effect/radiate/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	irradiate_in_dist(get_turf(holder), radiation_amount * used_power, range)
