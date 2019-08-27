/obj/effect/effect/aqueous_foam
	name = "aqueous film forming foam"
	icon_state = "afff_foam"

	opacity = FALSE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	layer = TURF_LAYER + 0.9

	animate_movement = FALSE

	var/disolving = FALSE
	var/image/fore_image

/obj/effect/effect/aqueous_foam/atom_init()
	. = ..()
	playsound(src, 'sound/effects/bubbles2.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/effect/aqueous_foam/atom_init_late()
	fore_image += image(icon, icon_state="afff_foam_fore", layer=MOB_LAYER + 0.9)
	overlays.Add(fore_image)

	var/turf/src_turf = get_turf(src)
	for(var/dir in cardinal)
		var/turf/T = get_step(src_turf, dir)
		var/obj/effect/effect/aqueous_foam/AFFF = locate(/obj/effect/effect/aqueous_foam) in T
		if(AFFF && !AFFF.disolving)
			AFFF.update_icon()
		else
			var/image/I = image(icon, icon_state="afff_foam_border", dir=dir, layer=layer)
			switch(dir)
				if(NORTH)
					I.pixel_y = 32
				if(SOUTH)
					I.pixel_y = -32
				if(WEST)
					I.pixel_x = -32
				if(EAST)
					I.pixel_x = 32
			overlays.Add(I)

	if(loc.density || !has_gravity(loc) || istype(get_turf(src), /turf/space))
		addtimer(CALLBACK(src, .proc/disolve), 5 SECONDS)

	INVOKE_ASYNC(src, .proc/performAction)

/obj/effect/effect/aqueous_foam/update_icon()
	overlays.Cut()
	overlays.Add(fore_image)

	var/turf/src_turf = get_turf(src)
	for(var/dir in cardinal)
		var/turf/T = get_step(src_turf, dir)
		var/obj/effect/effect/aqueous_foam/AFFF = locate(/obj/effect/effect/aqueous_foam) in T
		if(!AFFF || AFFF.disolving)
			var/image/I = image(icon, icon_state="afff_foam_border", dir=dir, layer=layer)
			switch(dir)
				if(NORTH)
					I.pixel_y = 32
				if(SOUTH)
					I.pixel_y = -32
				if(WEST)
					I.pixel_x = -32
				if(EAST)
					I.pixel_x = 32
			overlays.Add(I)

/obj/effect/effect/aqueous_foam/proc/disolve()
	if(disolving)
		return
	disolving = TRUE

	overlays.Remove(fore_image)
	flick("[icon_state]-disolve", src)
	sleep(5)

	var/turf/src_turf = get_turf(src)

	for(var/dir in cardinal)
		var/turf/T = get_step(src_turf, dir)
		var/obj/effect/effect/aqueous_foam/AFFF = locate(/obj/effect/effect/aqueous_foam) in T
		if(AFFF  && !AFFF.disolving)
			AFFF.update_icon()

	qdel(src)

/obj/effect/effect/aqueous_foam/Crossed(atom/movable/AM)
	if(istype(AM, /obj/effect/decal/chempuff))
		return

	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.w_class <= ITEM_SIZE_TINY)
			return

	if(ismob(AM))
		var/mob/M = AM
		if(M.lying || M.crawling)
			return

		if(isslime(AM)) // Slimes are vulnerable to us and shouldn't be able to destroy us.
			var/mob/living/carbon/slime/S = AM
			S.Weaken(5)
			S.adjustToxLoss(rand(15, 20))
			return

	INVOKE_ASYNC(src, .proc/disolve) // You should never call procs with delay from BYOND movement procs.

/obj/effect/effect/aqueous_foam/attack_hand(mob/user)
	disolve()

/obj/effect/effect/aqueous_foam/attackby(obj/item/I, mob/user)
	if(I.w_class > ITEM_SIZE_TINY)
		disolve()

/obj/effect/effect/aqueous_foam/proc/performAction()
	var/list/perform_on = list()
	var/turf/T = get_turf(src)

	var/hotspot = locate(/obj/fire) in T
	if(hotspot && istype(T, /turf/simulated))
		var/turf/simulated/sim_T = T
		var/datum/gas_mixture/lowertemp = sim_T.remove_air(sim_T.air.total_moles)
		lowertemp.temperature = max(min(lowertemp.temperature - 2000, lowertemp.temperature * 0.5) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

	for(var/atom/A in T.contents)
		perform_on += A.contents
		perform_on += A

	for(var/atom/A in perform_on)
		if(isliving(A))
			var/mob/living/L = A
			if(isslime(A)) // If only ExtinguishMob wasn't so vague, this could be there.
				L.adjustToxLoss(rand(15, 20))
			L.ExtinguishMob()
		else if(istype(A, /obj/structure/bonfire)) // Currently very snowflakey please fix later ~Luduk.
			var/obj/structure/bonfire/B = A
			B.extinguish()
		if(istype(A, /obj/item))
			var/obj/item/I = A
			I.extinguish()
		if(istype(A, /obj/effect/decal/cleanable/liquid_fuel))
			qdel(A)
