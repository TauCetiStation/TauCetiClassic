/turf/simulated
	name = "station"
	plane = FLOOR_PLANE

	var/wet = 0
	var/image/wet_overlay = null
	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	var/dirt = 0

	var/wet_timer_id

/turf/simulated/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/atom_init_late()
	levelupdate()

/turf/simulated/ChangeTurf()
	if(wet_timer_id)
		deltimer(wet_timer_id)
	return ..()

/turf/simulated/Entered(atom/A, atom/OL)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "<span class='warning'>Передвижение отключено администрацией.</span>")//This is to identify lag problems
		return

	if (iscarbon(A))
		var/mob/living/carbon/M = A
		if(M.lying && !M.crawling)
			return

		dirt++
		if (dirt >= 200)
			var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, src)

			if (!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(src)
				dirtoverlay.alpha = 20
			else
				dirtoverlay.alpha = min(dirtoverlay.alpha+5, 255)

	..()


//Wet floor procs.
/turf/simulated/proc/make_wet_floor(severity = WATER_FLOOR)
	wet_timer_id = addtimer(CALLBACK(src, PROC_REF(make_dry_floor)), rand(71 SECONDS, 80 SECONDS), TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	if(wet < severity)
		wet = severity
		UpdateSlip()
		if(!wet_overlay)
			var/current_type = "wet_floor"
			if(severity == LUBE_FLOOR)
				current_type = "wet_floor_static"
			wet_overlay = image('icons/effects/water.dmi', current_type, src)
			add_overlay(wet_overlay)

/turf/simulated/proc/make_dry_floor()
	if(wet)
		if(wet_overlay)
			cut_overlay(wet_overlay)
			wet_overlay = null
		wet = 0
		UpdateSlip()

/turf/simulated/proc/UpdateSlip()
	switch(wet)
		if(WATER_FLOOR)
			AddComponent(/datum/component/slippery, 2, NO_SLIP_WHEN_WALKING)
		if(LUBE_FLOOR)
			AddComponent(/datum/component/slippery, 5, SLIDE | GALOSHES_DONT_HELP)
		else
			qdel(GetComponent(/datum/component/slippery))

/turf/simulated/ex_act(severity) // todo: we need contents_explosion from tg
	for(var/thing in contents)
		var/atom/movable/movable_thing = thing
		if(QDELETED(movable_thing))
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += movable_thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += movable_thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += movable_thing
