/datum/component/wear_out

/datum/component/wear_out/Initialize()
	START_PROCESSING(SSgnaw, src)

/datum/component/wear_out/process()
	var/mob/living/simple_animal/animal = parent
	var/turf/target_turf = get_turf(parent)
	for(var/obj/structure/cable/C in target_turf)
		C.health -= animal.melee_damage

/datum/component/wear_out/Destroy()
	STOP_PROCESSING(SSgnaw, src)
	return ..()
