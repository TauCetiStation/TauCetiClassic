/proc/empulse(turf/epicenter, heavy_range, light_range, log=0)
	if(!epicenter) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [ADMIN_JMP(epicenter)]")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")

	var/power = heavy_range * 2 + light_range
	for(var/obj/item/device/radio/beacon/interaction_watcher/W in interaction_watcher_list)
		if(get_dist(W, epicenter) < 10)
			W.react_empulse(epicenter, power)

	if(heavy_range > 1)
		var/obj/effect/overlay/pulse = new /obj/effect/overlay(epicenter)
		pulse.icon = 'icons/effects/effects.dmi'
		pulse.icon_state = "emppulse"
		pulse.name = "emp pulse"
		pulse.anchored = 1
		QDEL_IN(pulse, 20)

	if(heavy_range > light_range)
		light_range = heavy_range

	for(var/mob/M in range(heavy_range, epicenter))
		M.playsound_local(null, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	for(var/atom/T in range(light_range, epicenter))
		var/distance = get_dist(epicenter, T)
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			T.emplode(1)
		else if(distance == heavy_range)
			if(prob(50))
				T.emplode(1)
			else
				T.emplode(2)
		else if(distance <= light_range)
			T.emplode(2)
	return 1
