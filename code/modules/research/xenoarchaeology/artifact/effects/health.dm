/datum/artifact_effect/heal
	effect_name = "Heal"
	effect_type = ARTIFACT_EFFECT_ORGANIC

/datum/artifact_effect/heal/proc/adjust_health(mob/living/receiver, healing_power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = GetAnomalySusceptibility(H)
		H.heal_overall_damage(healing_power * weakness, healing_power * weakness)
		H.updatehealth()
		return
	receiver.heal_overall_damage(healing_power, healing_power)
	receiver.updatehealth()

/datum/artifact_effect/heal/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	to_chat(user, "<span class='notice'>A soothing energy invigorate you.</span>")
	adjust_health(user, 25)

/datum/artifact_effect/heal/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		adjust_health(receiver, 1)

/datum/artifact_effect/heal/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		adjust_health(receiver, 5)

/datum/artifact_effect/heal/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy healed your wounds.</span>")
		adjust_health(receiver, 50)

/datum/artifact_effect/heal/roboheal
	effect_name = "Robo-heal"

/datum/artifact_effect/heal/roboheal/New()
	..()
	effect_type = pick(ARTIFACT_EFFECT_ELECTRO, ARTIFACT_EFFECT_PARTICLE)

/datum/artifact_effect/heal/roboheal/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(!issilicon(user))
		return
	to_chat(user, "<span class='notice'>Your systems report damaged components mending by themselves!</span>")
	adjust_health(user, 25)

/datum/artifact_effect/heal/roboheal/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Beneficial energy field detected!</span>")
		adjust_health(receiver, 1)

/datum/artifact_effect/heal/roboheal/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Structural damage has been repaired by energy pulse!</span>")
		adjust_health(receiver, 5)

/datum/artifact_effect/heal/roboheal/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Structural damage has been repaired by energy pulse!</span>")
		adjust_health(receiver, 50)

/datum/artifact_effect/hurt
	effect_name = "Hurt"

/datum/artifact_effect/hurt/proc/deal_damage(mob/living/receiver, damage_power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = GetAnomalySusceptibility(H)
		H.take_overall_damage(damage_power * weakness, damage_power * weakness)
		H.updatehealth()
		return
	receiver.heal_overall_damage(damage_power, damage_power)
	receiver.updatehealth()

/datum/artifact_effect/hurt/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	to_chat(user, "<span class='warning'>A painful discharge of energy strikes you!</span>")
	deal_damage(user, 10)
	return TRUE

/datum/artifact_effect/hurt/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='warning'>You feel a painful force radiating from something nearby.</span>")
		deal_damage(receiver, 1)

/datum/artifact_effect/hurt/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		deal_damage(receiver, 5)

/datum/artifact_effect/hurt/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='warning'>You feel tremendous pain</span>")
		deal_damage(receiver, 50)

/datum/artifact_effect/hurt/robohurt
	effect_name = "Robo-hurt"

/datum/artifact_effect/hurt/robohurt/New()
	..()
	effect_type = pick(ARTIFACT_EFFECT_ELECTRO, ARTIFACT_EFFECT_PARTICLE)

/datum/artifact_effect/hurt/robohurt/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(!issilicon(user))
		return
	to_chat(user, "<span class='warning'>Your systems report severe damage has been inflicted!</span>")
	deal_damage(user, 10)

/datum/artifact_effect/hurt/robohurt/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Harmful energy field detected!</span>")
		deal_damage(receiver, 1)

/datum/artifact_effect/hurt/robohurt/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(effectrange, curr_turf))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Structural damage inflicted by energy pulse!</span>")
		deal_damage(receiver, 5)

/datum/artifact_effect/hurt/robohurt/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Critical structural damage inflicted by energy pulse!</span>")
		deal_damage(receiver, 50)
