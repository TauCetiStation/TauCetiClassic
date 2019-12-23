
/datum/artifact_effect/gasoxy
	effect_name = "Gas Oxygen"
	var/max_pressure

/datum/artifact_effect/gasoxy/New()
	..()
	effect = pick(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	max_pressure = rand(115, 1000)
	effect_type = pick(ARTIFACT_EFFECT_BLUESPACE, ARTIFACT_EFFECT_SYNTH)


/datum/artifact_effect/gasoxy/DoEffectTouch(mob/user)
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("oxygen", rand(2, 15))

/datum/artifact_effect/gasoxy/DoEffectAura()
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("oxygen", pick(0, 0, 0.1, rand()))
