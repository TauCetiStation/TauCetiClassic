/datum/artifact_effect/teleport
	log_name = "Teleport"
	type_name = ARTIFACT_EFFECT_BLUESPACE

/datum/artifact_effect/teleport/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(teleport_around(user, 10))
		to_chat(user, "<span class='warning'>You are suddenly zapped away elsewhere!</span>")

/datum/artifact_effect/teleport/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/M in range(range, curr_turf))
		if(teleport_around(M, 20))
			to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")

/datum/artifact_effect/teleport/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/M in range(range, curr_turf))
		if(teleport_around(M, round(1 * used_power)))
			to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")

/datum/artifact_effect/teleport/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/M in range(7, curr_turf))
		if(teleport_around(M, 50))
			to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")

/datum/artifact_effect/teleport/proc/teleport_around(mob/receiver, max_range)
	var/weakness = get_anomaly_protection(receiver)
	if(!weakness)
		return FALSE
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 0, get_turf(receiver))
	sparks.start()
	var/turf/target_turf = pick(orange(get_turf(receiver), max_range * weakness))
	do_teleport(receiver, target_turf, 4)
	sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 0, get_turf(receiver))
	sparks.start()
	return TRUE
