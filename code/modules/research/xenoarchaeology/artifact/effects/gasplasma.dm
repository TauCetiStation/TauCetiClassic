
/datum/artifact_effect/gasphoron
	effect_name = "Gas Phoron"
	var/max_pressure
	var/target_percentage

/datum/artifact_effect/gasphoron/New()
	..()
	effect = pick(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	max_pressure = rand(115, 1000)
	effect_type = pick(ARTIFACT_EFFECT_BLUESPACE, ARTIFACT_EFFECT_SYNTH)

/datum/artifact_effect/gasphoron/DoEffectTouch(mob/user)
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("phoron", rand(2, 15))

/datum/artifact_effect/gasphoron/DoEffectAura()
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("phoron", pick(0, 0, 0.1, rand()))
