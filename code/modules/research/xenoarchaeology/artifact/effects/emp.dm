
/datum/artifact_effect/emp
	effect_name = "EMP"
	effect_type = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/emp/New()
	..()
	effect = ARTIFACT_EFFECT_PULSE

/datum/artifact_effect/emp/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		empulse(T, effectrange/2, effectrange)
		return 1
