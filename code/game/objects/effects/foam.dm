/obj/effect/effect/aqueous_foam
	name = "aqueous film forming foam"
	icon = 'icons/obj/smooth_objects/afff_foam1.dmi'
	icon_state = "box"

	opacity = FALSE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	layer = TURF_LAYER + 0.9

	animate_movement = FALSE

	var/disolving = FALSE
	var/image/fore_image

	var/shaking = FALSE

	canSmoothWith = list(/obj/effect/effect/aqueous_foam)
	smooth = SMOOTH_MORE

/obj/effect/effect/aqueous_foam/atom_init()
	. = ..()

	switch(rand(1, 4))
		if(1)
			icon = 'icons/obj/smooth_objects/afff_foam1.dmi'
		if(2)
			icon = 'icons/obj/smooth_objects/afff_foam2.dmi'
		if(3)
			icon = 'icons/obj/smooth_objects/afff_foam3.dmi'
		if(4)
			icon = 'icons/obj/smooth_objects/afff_foam4.dmi'

	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)

	pixel_x = -6
	pixel_y = -6 //so the sprites line up right in the map editor
	playsound(src, 'sound/effects/bubbles2.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/effect/aqueous_foam/atom_init_late()
	fore_image += image(icon, icon_state="afff_foam_fore", layer=MOB_LAYER + 0.9)
	add_overlay(fore_image)

	if(loc.density || !has_gravity(loc) || istype(get_turf(src), /turf/space))
		addtimer(CALLBACK(src, .proc/disolve), 5 SECONDS)

	INVOKE_ASYNC(src, .proc/performAction)

/obj/effect/effect/aqueous_foam/Destroy()
	if(smooth)
		queue_smooth_neighbors(src)
	QDEL_NULL(fore_image)
	return ..()

/obj/effect/effect/aqueous_foam/update_icon()
	cut_overlays()
	add_overlay(fore_image)

/obj/effect/effect/aqueous_foam/proc/disolve()
	if(disolving)
		return
	disolving = TRUE

	cut_overlay(fore_image)
	layer -= 0.01
	flick("afff_foam-disolve", src)
	QDEL_IN(src, 5)

/obj/effect/effect/aqueous_foam/proc/shake(max_shift = 5)
	if(QDELETED(src))
		return

	shaking = TRUE

	var/prev_pix_x = pixel_x
	var/prev_pix_y = pixel_y
	var/prev_icon_state = icon_state
	var/prev_smooth = smooth
	var/prev_appearance_flags = appearance_flags
	smooth = SMOOTH_FALSE
	appearance_flags |= PIXEL_SCALE

	var/pix_shift_x = rand(0, max_shift)
	var/pix_shift_y = rand(0, max_shift)

	var/matrix/M = matrix()
	M.Scale(1.2)

	icon_state = "box"
	animate(src, pixel_x = pixel_x + pix_shift_x, pixel_y = pixel_y + pix_shift_y, transform = M, time = 2)
	sleep(2)
	animate(src, pixel_x = prev_pix_x, pixel_y = prev_pix_y, transform = matrix(), time = 2)
	sleep(2)

	icon_state = prev_icon_state
	smooth = prev_smooth
	appearance_flags = prev_appearance_flags

	if(smooth)
		queue_smooth(src)

	shaking = FALSE

/obj/effect/effect/aqueous_foam/Crossed(atom/movable/AM)
	. = ..()

	if(istype(AM, /obj/effect/decal/chempuff))
		return

	if(AM.anchored || !AM.density)
		return

	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.w_class <= ITEM_SIZE_TINY)
			return

	if(isliving(AM))
		var/mob/living/L = AM
		if(L.lying || L.crawling)
			INVOKE_ASYNC(src, .proc/shake)
			return

		if(L.get_species() == SLIME) // Slimes are vulnerable to us and shouldn't be able to destroy us.
			L.Weaken(5)
			L.adjustToxLoss(rand(15, 20))
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
			if(L.get_species() == SLIME) // If only ExtinguishMob wasn't so vague, this could be there.
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
