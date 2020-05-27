/datum/holy_turf
	var/turf/simulated/floor/turf

	var/datum/religion/religion

	var/list/registered_aspects
	var/timer_id
	var/expiration_time

	var/max_time = 15 MINUTES

/datum/holy_turf/New(turf/simulated/floor/F, datum/religion/R, reagent_volume)
	turf = F
	religion = R

	if(turf.holy)
		qdel(turf.holy)
	turf.holy = src

	for(var/aspect_name in religion.aspects)
		var/datum/aspect/A = religion.aspects[aspect_name]
		LAZYADD(registered_aspects, A)
		A.register_holy_turf(turf, religion)
		LAZYADD(A.holy_turfs, turf)

	religion.holy_turfs[turf] = src

	var/time_to_expire = reagent_volume * 1 MINUTE
	time_to_expire = min(time_to_expire, max_time)

	expiration_time = world.time + time_to_expire

	timer_id = create_timer(time_to_expire)

/datum/holy_turf/Destroy()
	deltimer(timer_id)

	for(var/aspect_name in religion.aspects)
		var/datum/aspect/A = religion.aspects[aspect_name]
		A.unregister_holy_turf(turf, religion)
		LAZYREMOVE(registered_aspects, A)
		LAZYREMOVE(A.holy_turfs, turf)

	registered_aspects = null

	religion.holy_turfs -= turf

	turf.holy = null

	turf = null
	religion = null
	return ..()

/datum/holy_turf/proc/create_timer(time_to_expire)
	return addtimer(CALLBACK(religion, /datum/religion.proc/remove_holy_turf, turf), time_to_expire, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/holy_turf/proc/update(reagent_volume)
	var/time_to_expire = expiration_time - world.time + reagent_volume * 1 MINUTE
	time_to_expire = min(time_to_expire, max_time)
	deltimer(timer_id)
	timer_id = create_timer(time_to_expire)
