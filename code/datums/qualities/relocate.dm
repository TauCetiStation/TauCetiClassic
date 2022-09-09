/datum/quality/relocate
	pools = list(
		QUALITY_POOL_QUIRKIEISH
	)

	var/list/area/target_area = list()
	var/turf/target_turf = null

/datum/quality/relocate/proc/setup()
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

/datum/quality/relocate/tajaran_prisoner
	name = "Tajaran"
	desc = "Пройдя ускоренный курс подготовки к работе в космосе, ты овладел навыками во многих сферах деятельности, но достичь мастерства не удалось ни в одной."
	requirement = "Нет."
	target_area = list(/area/station/cargo/storage )

/datum/quality/relocate/tajaran_prisoner/add_effect(mob/living/carbon/human/H, latespawn)
	if(H.wear_mask)
		qdel(H.wear_mask)
	/*if(H.belt)
		qdel(H.belt)
	if(w.uniformas)*/
	if(H.head)
		qdel(H.head)
	if(H.wear_suit)
		qdel(H.wear_suit)
	if(H.back)
		qdel(H.back)
	/*if(H.shoes)
		qdel(H.shoes)*/
	if(H.l_ear)
		qdel(H.l_ear)
	/*H.remove_from_mob(H.w_uniform)
	H.remove_from_mob(H.head)
	H.remove_from_mob(H.wear_suit)
	H.remove_from_mob(H.back)
	H.remove_from_mob(H.shoes)*/

	H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs/cable(H), SLOT_HANDCUFFED)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/tie/collar(H), SLOT_WEAR_MASK)
	/*H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), SLOT_SHOES)*/

	var/spawn_loc = get_turf(H.loc)
	var/obj/structure/closet/critter/C = new(spawn_loc)
	H.loc = C
	var/obj/structure/bigDelivery/P = new(spawn_loc)
	C.loc = P
