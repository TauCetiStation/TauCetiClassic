/datum/quality/relocate
	pools = list(
		QUALITY_POOL_QUIRKIEISH
	)
	/*
	Fill in one of the two fields to move there at the beginning of the round
	Check SSjobs substystem for more info
	*/
	var/list/area/target_area = list()
	var/turf/target_turf = null

/datum/quality/relocate/proc/setup()
	if(target_turf)
		return target_turf
	if(target_area.len)
		var/area/avaible_area = get_area_by_type(pick(target_area))
		var/list/list_of_turfs = list()
		var/list/all_atoms = avaible_area.GetAreaAllContents()
		for(var/turf/simulated/T in all_atoms)
			if(!T)
				return null
			if(T.density == 1)
				continue
			var/list/obj = list()
			for(var/i in T.contents)
				if(istype(i, /atom/movable/lighting_object))
					continue
				if(i)
					obj += i
			if(obj.len)
				continue
			list_of_turfs += T
		if(list_of_turfs.len)
			target_turf = pick(list_of_turfs)
			return target_turf

/datum/quality/relocate/proc/get_spawn_turf()
	if(target_turf)
		return target_turf
	else
		var/generate_turf = setup()
		if(generate_turf)
			return generate_turf

/datum/quality/relocate/special_case
	name = "Special case"
	desc = "У тебя сегодня очень плохой день. Возможно, ты помнишь как оказался здесь и откуда у тебя эти раны."
	requirement = "Нет."
	//slimes from xenobio gets alot time for awaking and get away from cell
	target_area = list(
				/area/station/cargo/miningoffice,
				/area/station/cargo/storage,
				/area/station/engineering/engine,
				/area/station/engineering/drone_fabrication,
				/area/station/maintenance/escape,
				/area/station/maintenance/incinerator,
				/area/station/bridge/nuke_storage,
				/area/station/gateway,
				/area/station/medical/medbreak,
				/area/station/medical/psych,
				/area/station/security/execution,
				/area/station/security/prison,
				/area/station/security/armoury,
				/area/station/rnd/xenobiology,
				/area/station/storage/emergency2,
				/area/station/storage/tech,
				/area/station/aisat/teleport,
				)

/datum/quality/relocate/special_case/add_effect(mob/living/carbon/human/H, latespawn)
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
