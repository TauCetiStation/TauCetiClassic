
/datum/artifact_effect/emp
	effect_name = "EMP"
	effect_type = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/emp/New()
	..()
	effect = ARTIFACT_EFFECT_PULSE

/datum/artifact_effect/emp/DoEffectPulse()
	if(!holder)
		return FALSE
	empulse(get_turf(holder), effectrange / 2, effectrange)
	return TRUE
