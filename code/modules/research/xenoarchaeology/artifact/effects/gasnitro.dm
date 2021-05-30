
/datum/artifact_effect/gasnitro
	effect_name = "Gas Nitro"
	var/max_pressure
	var/target_percentage

/datum/artifact_effect/gasnitro/New()
	..()
	effect = pick(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	effect_type = pick(ARTIFACT_EFFECT_BLUESPACE, ARTIFACT_EFFECT_SYNTH)
	max_pressure = rand(115, 1000)

/datum/artifact_effect/gasnitro/DoEffectTouch(mob/user)
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("nitrogen", rand(2, 15))

/datum/artifact_effect/gasnitro/DoEffectAura()
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("nitrogen", pick(0, 0, 0.1, rand()))
