/datum/objective/gang/steal_lowrisk
    var/obj/item/steal_target
    var/static/items_to_steal = list(/obj/item/weapon/card/id/captains_spare,
									 /obj/item/weapon/disk/nuclear,
									 /obj/item/weapon/stamp/med/cmo,
									 /obj/item/weapon/stamp/hop,
									 /obj/item/weapon/stamp/cap,
									 /obj/item/weapon/stamp/sec/hos,
									 /obj/item/weapon/stamp/sci/rd,
									 /obj/item/weapon/stamp/eng/ce,
									 /obj/item/weapon/stamp/cargo/qm,
									 /obj/item/device/remote_device/chief_medical_officer,
									 /obj/item/device/remote_device/captain,
									 /obj/item/device/remote_device/chief_engineer,
									 /obj/item/device/remote_device/research_director,
									 /obj/item/device/remote_device/quartermaster,
									 /obj/item/device/remote_device/head_of_security,
									 /obj/item/device/remote_device/head_of_personal,
									 /obj/item/toy/plushie/space_whale,
									 /obj/item/clothing/mask/facehugger/lamarr,
									 /obj/item/clothing/accessory/armor/dermal
									)


/datum/objective/gang/steal_lowrisk/New()
	LAZYINITLIST(lowrisk_objectives_cache)
	select_target()

/datum/objective/gang/steal_lowrisk/select_target()
	steal_target = find_and_check_target()
	explanation_text = "Steal [initial(steal_target.name)]."

var/global/list/lowrisk_objectives_cache

/datum/objective/gang/steal_lowrisk/proc/find_and_check_target()
	if(global.lowrisk_objectives_cache.len == 2)
		return pick(global.lowrisk_objectives_cache)
	var/target = pick(items_to_steal)
	global.lowrisk_objectives_cache += target
	items_to_steal -= target
	return target

/datum/objective/gang/steal_lowrisk/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue
		var/list/items_to_check = M.GetAllContents()
		var/item_found = locate(steal_target) in items_to_check
		if(item_found)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
