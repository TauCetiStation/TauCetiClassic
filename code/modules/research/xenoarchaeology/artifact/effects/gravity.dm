#define GRAVITY_PULL 0
#define GRAVITY_REPELL 1

/datum/artifact_effect/gravity
	log_name = "Gravity"
	var/grav_type

/datum/artifact_effect/gravity/New()
	..()
	trigger = TRIGGER_TOUCH
	release_method = ARTIFACT_EFFECT_PULSE
	type_name = ARTIFACT_EFFECT_BLUESPACE
	grav_type = pick(GRAVITY_PULL, GRAVITY_REPELL)

/datum/artifact_effect/gravity/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(range, curr_turf))
		calc_protection_and_step(receiver, curr_turf)

/datum/artifact_effect/gravity/proc/calc_protection_and_step(mob/living/M, turf/T)
	var/protection = get_anomaly_protection(M)
	if(!protection)
		return
	var/turfs_to_step = 0
	turfs_to_step = round(protection * 10 / 2) //5 turfs in no protection, 1 turf in 0,1 protection
	while(turfs_to_step > 0)
		grav_type ? step_away(M, T) : step_towards(M, T)
		turfs_to_step--

#undef GRAVITY_PULL
#undef GRAVITY_REPELL
