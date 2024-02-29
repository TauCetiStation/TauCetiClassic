/datum/objective/gang/steal_lowrisk
		var/obj/item/steal_target
		var/target_name
		var/list/items_to_steal = list()
		var/static/possible_lowrisk[] = list(
			"диск ядерной аутентификации" = /obj/item/weapon/disk/nuclear,
			"штамп СМО" = /obj/item/weapon/stamp/med/cmo,
			"штамп ГП" = /obj/item/weapon/stamp/hop,
			"штамп капитана" = /obj/item/weapon/stamp/cap,
			"штамп ГСБ" = /obj/item/weapon/stamp/sec/hos,
			"штамп научрука" = /obj/item/weapon/stamp/sci/rd,
			"штамп СИ" =  /obj/item/weapon/stamp/eng/ce,
			"штамп завхоза" = /obj/item/weapon/stamp/cargo/qm,
			"пульт удалённого управления \"Медблок\"" = /obj/item/device/remote_device/chief_medical_officer,
			"пульт удалённого управления \"Командный\"" = /obj/item/device/remote_device/captain,
			"пульт удалённого управления \"Инженерный\"" = /obj/item/device/remote_device/chief_engineer,
			"пульт удалённого управления \"Научный\"" = /obj/item/device/remote_device/research_director,
			"пульт удалённого управления \"Снабжение\"" = /obj/item/device/remote_device/quartermaster,
			"пульт удалённого управления \"Служба Безопасности\"" = /obj/item/device/remote_device/head_of_security,
			"пульт удалённого управления \"Гражданские отделы\"" = /obj/item/device/remote_device/head_of_personal,
			"плюшевого космокита" =  /obj/item/toy/plushie/space_whale,
			"лицехвата Ламарра"	= /obj/item/clothing/mask/facehugger/lamarr,
			"дермальную накладку" = /obj/item/clothing/accessory/armor/dermal
  )

/datum/objective/gang/steal_lowrisk/proc/get_possible_lowrisk()
	return possible_lowrisk

/datum/objective/gang/steal_lowrisk/New()
	. = ..()
	items_to_steal = get_possible_lowrisk()

/datum/objective/gang/steal_lowrisk/proc/set_target(item_name)
	target_name = item_name
	steal_target = items_to_steal[target_name]
	explanation_text = "Украдите [target_name]."
	return steal_target

/datum/objective/gang/steal_lowrisk/find_target()
	set_target(pick(items_to_steal))
	return TRUE

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
