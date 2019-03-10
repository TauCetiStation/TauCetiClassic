
/datum/artifact_effect/emp
	effect_name = "emp"
	effect_type = 3

/datum/artifact_effect/emp/New()
	..()
	effect = EFFECT_PULSE

/datum/artifact_effect/emp/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		empulse(T, effectrange/2, effectrange)
		return 1
