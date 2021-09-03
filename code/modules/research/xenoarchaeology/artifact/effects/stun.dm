/datum/artifact_effect/stun
	effect_name = "Stun"

/datum/artifact_effect/stun/New()
	..()
	effect_type = pick(ARTIFACT_EFFECT_PSIONIC, ARTIFACT_EFFECT_ORGANIC)

/datum/artifact_effect/stun/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(apply_effect(user, 5))
		to_chat(user, "<span class='warning'>A powerful force overwhelms your consciousness.</span>")

/datum/artifact_effect/stun/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/L in range(effectrange, curr_turf))
		if(!prob(20))
			continue
		if(apply_effect(L, 2))
			to_chat(L, "<span class='warning'>Your body goes numb for a moment.</span>")

/datum/artifact_effect/stun/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/L in range(effectrange, curr_turf))
		if(!prob(50))
			continue
		if(apply_effect(L, 5))
			to_chat(L, "<span class='warning'>A wave of energy overwhelms your senses!</span>")

/datum/artifact_effect/stun/proc/apply_effect(mob/receiver, power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakened = GetAnomalySusceptibility(H)
		if(!weakened)
			return FALSE
		H.AdjustWeakened(power * weakened)
		H.AdjustStunned(power * weakened)
		H.stuttering += power * weakened
		return TRUE
	receiver.AdjustWeakened(power)
	receiver.AdjustStunned(power)
	receiver.stuttering += power
	return TRUE
