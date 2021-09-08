/datum/artifact_effect/heal
	log_name = "Heal"
	type_name = ARTIFACT_EFFECT_ORGANIC

/datum/artifact_effect/heal/proc/heal_target(mob/living/receiver, healing_power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = get_anomaly_protection(H)
		H.heal_overall_damage(healing_power * weakness, healing_power * weakness)
		return
	receiver.heal_overall_damage(healing_power, healing_power)

/datum/artifact_effect/heal/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	to_chat(user, "<span class='notice'>A soothing energy invigorate you.</span>")
	heal_target(user, 25)

/datum/artifact_effect/heal/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		heal_target(receiver, 1)

/datum/artifact_effect/heal/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		heal_target(receiver, 5 * used_power)

/datum/artifact_effect/heal/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy healed your wounds.</span>")
		heal_target(receiver, 50)

/datum/artifact_effect/roboheal
	log_name = "Robo-heal"

/datum/artifact_effect/roboheal/New()
	..()
	type_name = pick(ARTIFACT_EFFECT_ELECTRO, ARTIFACT_EFFECT_PARTICLE)

/datum/artifact_effect/roboheal/proc/heal_target(mob/living/receiver, healing_power)
	receiver.heal_overall_damage(healing_power, healing_power)

/datum/artifact_effect/roboheal/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(!issilicon(user))
		return
	to_chat(user, "<span class='notice'>Your systems report damaged components mending by themselves!</span>")
	heal_target(user, 25)

/datum/artifact_effect/roboheal/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Beneficial energy field detected!</span>")
		heal_target(receiver, 1)

/datum/artifact_effect/roboheal/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Structural damage has been repaired by energy pulse!</span>")
		heal_target(receiver, 5 * used_power)

/datum/artifact_effect/roboheal/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='notice'>SYSTEM ALERT: Structural damage has been repaired by energy pulse!</span>")
		heal_target(receiver, 50)

/datum/artifact_effect/hurt
	log_name = "Hurt"

/datum/artifact_effect/hurt/proc/deal_damage(mob/living/receiver, damage_power)
	if(ishuman(receiver))
		var/mob/living/carbon/human/H = receiver
		var/weakness = get_anomaly_protection(H)
		H.take_overall_damage(damage_power * weakness, damage_power * weakness)
		return
	receiver.take_overall_damage(damage_power, damage_power)

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
	for(var/mob/living/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='warning'>You feel a painful force radiating from something nearby.</span>")
		deal_damage(receiver, 1)

/datum/artifact_effect/hurt/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='notice'>A wave of energy invigorates you.</span>")
		deal_damage(receiver, 5 * used_power)

/datum/artifact_effect/hurt/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='warning'>You feel tremendous pain</span>")
		deal_damage(receiver, 50)

/datum/artifact_effect/robohurt
	log_name = "Robo-hurt"

/datum/artifact_effect/robohurt/New()
	..()
	type_name = pick(ARTIFACT_EFFECT_ELECTRO, ARTIFACT_EFFECT_PARTICLE)

/datum/artifact_effect/robohurt/proc/deal_damage(mob/living/receiver, damage_power)
	receiver.take_overall_damage(damage_power, damage_power)

/datum/artifact_effect/robohurt/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(!issilicon(user))
		return
	to_chat(user, "<span class='warning'>Your systems report severe damage has been inflicted!</span>")
	deal_damage(user, 10)

/datum/artifact_effect/robohurt/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Harmful energy field detected!</span>")
		deal_damage(receiver, 1)

/datum/artifact_effect/robohurt/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/silicon/receiver in range(range, curr_turf))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Structural damage inflicted by energy pulse!</span>")
		deal_damage(receiver, 0.5 * used_power)

/datum/artifact_effect/robohurt/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(7, curr_turf))
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: Critical structural damage inflicted by energy pulse!</span>")
		deal_damage(receiver, 50)
