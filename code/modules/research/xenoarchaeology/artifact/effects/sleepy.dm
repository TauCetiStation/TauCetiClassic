/datum/artifact_effect/sleepy
	log_name = "Sleepy"

/datum/artifact_effect/sleepy/New()
	..()
	type_name = pick(ARTIFACT_EFFECT_PSIONIC, ARTIFACT_EFFECT_ORGANIC)

/datum/artifact_effect/sleepy/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	apply_sleepy(user, 25)

/datum/artifact_effect/sleepy/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/L in range(range, curr_turf))
		if(prob(50))
			apply_sleepy(L, 5)

/datum/artifact_effect/sleepy/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/L in range(range, curr_turf))
		apply_sleepy(L, used_power)


/datum/artifact_effect/sleepy/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/L in range(7, curr_turf))
		var/weakness = get_anomaly_protection(L)
		if(!weakness)
			continue
		L.SetSleeping(weakness * (10 SECONDS)) //0 resistance gives you 10 seconds of sleep

/datum/artifact_effect/sleepy/proc/apply_sleepy(mob/receiver, power)
	if(ishuman(receiver) && !receiver.is_mechanical())
		var/mob/living/carbon/human/H = receiver
		var/weakness = get_anomaly_protection(H)
		if(!weakness)
			return
		to_chat(H, pick("<span class='notice'>You feel like taking a nap.</span>","<span class='notice'>You feel a yawn coming on.</span>","<span class='notice'>You feel a little tired.</span>"))
		H.drowsyness = H.drowsyness + power * weakness
		H.adjustBlurriness(power * weakness)
	if(receiver.is_mechanical())
		to_chat(receiver, "<span class='warning'>SYSTEM ALERT: CPU cycles slowing down.</span>")
