
/datum/artifact_effect/gasco2
	effect_name = "Gas CO2"
	var/max_pressure
	var/target_percentage

/datum/artifact_effect/gasco2/New()
	..()
	effect = pick(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	effect_type = pick(ARTIFACT_EFFECT_BLUESPACE, ARTIFACT_EFFECT_SYNTH)
	max_pressure = rand(115, 1000)

/datum/artifact_effect/gasco2/DoEffectTouch(mob/user)
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("carbon_dioxide", rand(2, 15))

/datum/artifact_effect/gasco2/DoEffectAura()
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("carbon_dioxide", pick(0, 0, 0.1, rand()))
