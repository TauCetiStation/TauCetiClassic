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

/datum/artifact_effect/gravity/DoEffectPulse(atom/holder)
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/M in range(range, curr_turf))
		step_towards(M, curr_turf)

/datum/artifact_effect/gravity/proc/calc_protection_and_step(mob/living/M, turf/T)
	var/protection = get_anomaly_protection(M)
	if(!protection)
		return
	var/turfs_to_step = 0
	turfs_to_step = round(protection * 10 / 2) //5 turfs in no protection, 1 turf in 0,1 protection
	grav_type ? step_away(M, T, turfs_to_step) : step_towards(M, T, turfs_to_step)

#undef GRAVITY_PULL
#undef GRAVITY_REPELL
