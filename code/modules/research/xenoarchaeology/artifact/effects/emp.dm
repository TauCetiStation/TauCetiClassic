/datum/artifact_effect/emp
	log_name = "EMP"
	type_name = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/emp/New()
	..()
	release_method = ARTIFACT_EFFECT_PULSE

/datum/artifact_effect/emp/DoEffectPulse()
	. = ..()
	if(!.)
		return
	empulse(get_turf(holder), range / 2, range)

/datum/artifact_effect/emp/DoEffectDestroy()
	empulse(get_turf(holder), 7, range, custom_effects = EMP_SEBB)
