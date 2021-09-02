/datum/artifact_effect/heal
	effect_name = "Heal"
	effect_type = ARTIFACT_EFFECT_ORGANIC

/datum/artifact_effect/heal/proc/adjust_health(mob/living/receiver, healing_power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = GetAnomalySusceptibility(H)
		H.adjustBrainLoss(-healing_power * weakness)
		H.radiation -= min(H.radiation, healing_power * weakness)
		H.heal_overall_damage(healing_power * weakness, healing_power * weakness)
		H.adjustOxyLoss(-healing_power * weakness)
		H.adjustToxLoss(-healing_power * weakness)
		H.updatehealth()
		return
	receiver.adjustOxyLoss(healing_power)
	receiver.adjustToxLoss(healing_power)
	receiver.heal_overall_damage(healing_power ,healing_power)
	receiver.updatehealth()

/datum/artifact_effect/heal/DoEffectTouch(mob/toucher)
	if(!toucher)
		return FALSE
	to_chat(toucher, "<span class='notice'>A soothing energy invigorate you.</span>")
	adjust_health(toucher, 25)
	return TRUE

/datum/artifact_effect/heal/DoEffectAura()
	if(!holder)
		return
	for(var/mob/living/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		adjust_health(receiver, 1)

/datum/artifact_effect/heal/DoEffectPulse()
	if(!holder)
		return
	for(var/mob/living/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		adjust_health(receiver, 5)

/datum/artifact_effect/heal/roboheal
	effect_name = "Robo-heal"

/datum/artifact_effect/heal/roboheal/New()
	..()
	effect_type = pick(ARTIFACT_EFFECT_ELECTRO, ARTIFACT_EFFECT_PARTICLE)

/datum/artifact_effect/heal/roboheal/DoEffectTouch(mob/toucher)
	if(!toucher)
		return FALSE
	if(!issilicon(toucher))
		return
	to_chat(toucher, "<span class='notice'>Your systems report damaged components mending by themselves!</span>")
	adjust_health(toucher, 25)
	return TRUE

/datum/artifact_effect/heal/roboheal/DoEffectAura()
	if(!holder)
		return
	for(var/mob/living/silicon/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Beneficial energy field detected!</span>")
		adjust_health(receiver, 1)

/datum/artifact_effect/heal/roboheal/DoEffectPulse()
	if(!holder)
		return
	for(var/mob/living/silicon/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Structural damage has been repaired by energy pulse!</span>")
		adjust_health(receiver, 5)

/datum/artifact_effect/hurt
	effect_name = "Hurt"

/datum/artifact_effect/hurt/proc/deal_damage(mob/living/receiver, damage_power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = GetAnomalySusceptibility(H)
		H.adjustBrainLoss(damage_power * weakness)
		H.radiation += min(H.radiation, damage_power * weakness)
		H.take_overall_damage(damage_power * weakness, damage_power * weakness)
		H.adjustOxyLoss(damage_power * weakness)
		H.adjustToxLoss(damage_power * weakness)
		H.updatehealth()
		return
	receiver.adjustOxyLoss(damage_power)
	receiver.adjustToxLoss(damage_power)
	receiver.heal_overall_damage(damage_power, damage_power)
	receiver.updatehealth()

/datum/artifact_effect/hurt/DoEffectTouch(mob/user)
	if(!user)
		return FALSE
	to_chat(user, "<span class='warning'>A painful discharge of energy strikes you!</span>")
	deal_damage(user, 20)
	return TRUE

/datum/artifact_effect/hurt/DoEffectAura()
	if(!holder)
		return
	for(var/mob/living/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='warning'>You feel a painful force radiating from something nearby.</span>")
		deal_damage(receiver, 1)

/datum/artifact_effect/hurt/DoEffectPulse()
	if(!holder)
		return
	for(var/mob/living/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		deal_damage(receiver, 5)

/datum/artifact_effect/hurt/robohurt
	effect_name = "Robo-hurt"

/datum/artifact_effect/hurt/robohurt/New()
	..()
	effect_type = pick(ARTIFACT_EFFECT_ELECTRO, ARTIFACT_EFFECT_PARTICLE)

/datum/artifact_effect/hurt/robohurt/DoEffectTouch(mob/toucher)
	if(!toucher)
		return FALSE
	if(!issilicon(toucher))
		return
	to_chat(toucher, "<span class='warning'>Your systems report severe damage has been inflicted!</span>")
	deal_damage(toucher, 25)
	return TRUE

/datum/artifact_effect/hurt/robohurt/DoEffectAura()
	if(!holder)
		return
	for(var/mob/living/silicon/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Harmful energy field detected!</span>")
		deal_damage(receiver, 1)

/datum/artifact_effect/hurt/robohurt/DoEffectPulse()
	if(!holder)
		return
	for(var/mob/living/silicon/receiver in range(effectrange, holder))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Structural damage inflicted by energy pulse!</span>")
		deal_damage(receiver, 10)
