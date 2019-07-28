/obj/effect/effect/afff_foam
	name = "aqueous film forming foam"
	icon_state = "afff_foam"

	opacity = FALSE
	anchored = TRUE
	density = FALSE

	layer = OBJ_LAYER + 0.9
	animate_movement = FALSE

/obj/effect/effect/afff_foam/atom_init()
	. = ..()
	playsound(src, 'sound/effects/bubbles2.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/effect/afff_foam/atom_init_late()
	INVOKE_ASYNC(src, .proc/process_foam)

/obj/effect/effect/afff_foam/proc/process_foam()
	performAction()
	sleep(15 SECONDS)
	if(src) // Since we can get removed by being stepped on.
		disolve()

/obj/effect/effect/afff_foam/proc/disolve()
	flick("[icon_state]-disolve", src)
	sleep(5)
	qdel(src)

/obj/effect/effect/afff_foam/Crossed(atom/movable/AM)
	if(isslime(AM)) // Slimes are vulnerable to us and shouldn't be able to destroy us.
		var/mob/living/carbon/slime/S = AM
		S.Stun(5)
	else
		INVOKE_ASYNC(src, .proc/disolve) // You should never call procs with delay from BYOND movement procs.

/obj/effect/effect/afff_foam/proc/performAction()
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
			L.ExtinguishMob()
		else if(istype(A, /obj/structure/bonfire)) // Currently very snowflakey please fix later ~Luduk.
			var/obj/structure/bonfire/B = A
			B.extinguish()
		if(istype(A, /obj/item))
			var/obj/item/I = A
			I.extinguish()
