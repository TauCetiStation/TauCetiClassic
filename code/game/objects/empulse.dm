/obj/effect/overlay/temp/heavy_emp
	icon = 'icons/effects/sebb.dmi'
	icon_state = "sebb_explode"
	layer = ABOVE_LIGHTING_PLANE
	pixel_x = -175 // We need these offsets to force center the sprite because BYOND is dumb
	pixel_y = -175
	appearance_flags = RESET_COLOR

/proc/empulse(turf/epicenter, heavy_range, light_range, log=0, custom_effects = EMP_DEFAULT)
	if(!epicenter) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [ADMIN_JMP(epicenter)]")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")

	SSStatistics.add_emp_stat(epicenter, heavy_range, light_range)

	SEND_SIGNAL(SSexplosions, COMSIG_EXPLOSIONS_EMPULSE, epicenter, heavy_range, light_range)

	if(custom_effects == EMP_SEBB)
		var/obj/effect/overlay/temp/heavy_emp/S = new(epicenter)
		S.anchored = TRUE
		QDEL_IN(S, 1 SECOND)
	else if(heavy_range > 1)
		var/obj/effect/overlay/pulse = new /obj/effect/overlay(epicenter)
		pulse.icon = 'icons/effects/effects.dmi'
		pulse.icon_state = "emppulse"
		pulse.name = "emp pulse"
		pulse.anchored = TRUE
		QDEL_IN(pulse, 2 SECONDS)

	if(heavy_range > light_range)
		light_range = heavy_range
	for(var/mob/M in range(heavy_range, epicenter))
		M.playsound_local(null, custom_effects, VOL_EFFECTS_MASTER, null, FALSE)

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
