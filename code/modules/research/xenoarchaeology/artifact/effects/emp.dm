/datum/artifact_effect/emp
	effect_name = "EMP"
	effect_type = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/emp/New()
	..()
	effect = ARTIFACT_EFFECT_PULSE

/datum/artifact_effect/emp/DoEffectPulse()
	. = ..()
	if(!.)
		return
	empulse(get_turf(holder), effectrange / 2, effectrange)

/datum/artifact_effect/emp/DoEffectDestroy()
	empulse(get_turf(holder), 7, effectrange)
