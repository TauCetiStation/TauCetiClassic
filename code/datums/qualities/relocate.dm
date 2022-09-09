/datum/quality/relocate
	pools = list(
		QUALITY_POOL_QUIRKIEISH
	)
	/*
	Fill in the sheet with the type of landmark you have set on the map
	*/
	var/list/quality_landmarks = list()


/datum/quality/relocate/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/effect/landmark/quality_relocate/spawn_landmark = pick(quality_landmarks)
	if(!spawn_landmark)
		return
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/quality_relocate/Q in global.quality_landmarks)
		if(!Q)
			return
		if(istype(Q, spawn_landmark))
			spawn_locs += Q.loc
	if(spawn_locs.len)
		H.forceMove(pick(spawn_locs))

/datum/quality/relocate/bad_day
	name = "Bad Day"
	desc = "У тебя сегодня очень плохой день. Возможно, ты помнишь как оказался здесь и откуда у тебя эти раны."
	requirement = "Нет."
	quality_landmarks = list(/obj/effect/landmark/quality_relocate/bad_day)

/datum/quality/relocate/bad_day/add_effect(mob/living/carbon/human/H, latespawn)
	. = ..()
	var/list/slots = H.get_all_slots()
	for(var/obj/W in slots)
		if(W == H.wear_id)
			continue
		if(W == H.l_ear)
			continue
		qdel(W)
	H.AdjustDrunkenness(500)
	H.adjust_bodytemperature(-300, min_temp = 0)
	H.adjustBruteLoss(100)
	H.AdjustSleeping(150, ignore_sleepimmune = TRUE)
