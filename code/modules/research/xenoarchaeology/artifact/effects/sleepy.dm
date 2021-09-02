
//todo
/datum/artifact_effect/sleepy
	effect_name = "Sleepy"

/datum/artifact_effect/sleepy/New()
	..()
	effect_type = pick(ARTIFACT_EFFECT_PSIONIC, ARTIFACT_EFFECT_ORGANIC)

/datum/artifact_effect/sleepy/DoEffectTouch(mob/toucher)
	if(!toucher)
		return FALSE
	apply_effect(toucher)
	return TRUE

/datum/artifact_effect/sleepy/DoEffectAura()
	if(!holder)
		return FALSE
	for(var/mob/living/L in range(effectrange, holder))
		if(prob(50))
			apply_effect(L)
	return TRUE

/datum/artifact_effect/sleepy/DoEffectPulse()
	if(!holder)
		return FALSE
	for(var/mob/living/L in range(effectrange, holder))
		apply_effect(L)
	return TRUE

/datum/artifact_effect/sleepy/proc/apply_effect(mob/receiver)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = GetAnomalySusceptibility(H)
		if(!weakness)
			return
		to_chat(H, pick("<span class='notice'>You feel like taking a nap.</span>","<span class='notice'>You feel a yawn coming on.</span>","<span class='notice'>You feel a little tired.</span>"))
		H.drowsyness = min(H.drowsyness + 10 * weakness, 50 * weakness)
		H.eye_blurry = min(H.eye_blurry + 10 * weakness, 50 * weakness)
	if(isrobot(receiver))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: CPU cycles slowing down.</span>")
