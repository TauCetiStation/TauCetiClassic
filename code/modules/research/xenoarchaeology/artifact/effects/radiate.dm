/datum/artifact_effect/radiate
	effect_name = "Radiate"
	var/radiation_amount

/datum/artifact_effect/radiate/New()
	..()
	radiation_amount = rand(1, 10)
	effect_type = pick(ARTIFACT_EFFECT_PARTICLE, ARTIFACT_EFFECT_ORGANIC)

/datum/artifact_effect/radiate/DoEffectTouch(mob/living/user)
	. = ..()
	if(!.)
		return
	user.apply_effect(radiation_amount * 5, IRRADIATE, 0)
	user.updatehealth()

/datum/artifact_effect/radiate/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/M in range(effectrange, curr_turf))
		M.apply_effect(radiation_amount, IRRADIATE, 0)
		M.updatehealth()

/datum/artifact_effect/radiate/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/M in range(effectrange, curr_turf))
		M.apply_effect(radiation_amount * 25, IRRADIATE, 0)
		M.updatehealth()
