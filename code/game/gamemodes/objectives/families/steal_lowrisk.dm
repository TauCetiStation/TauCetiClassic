var/global/list/possible_lowrisk_items_to_steal = list()

/datum/objective/gang/steal_lowrisk
    var/obj/item/steal_target
    var/static/items_to_steal = list("запасная карта капитана" = /obj/item/weapon/card/id/captains_spare,
									 "диск от ядерной боеголовки" = /obj/item/weapon/disk/nuclear,
									 "печать СМО" = /obj/item/weapon/stamp/cmo,
									 "печать ГП" = /obj/item/weapon/stamp/hop,
									 "печать капитана" = /obj/item/weapon/stamp/captain,
									 "печать ГСБ" = /obj/item/weapon/stamp/hos,
									 "печать ДИР" = /obj/item/weapon/stamp/rd,
									 "печать СИ" = /obj/item/weapon/stamp/ce,
									 "печать КМ" = /obj/item/weapon/stamp/qm,
									 "пульт ДУ шлюзами медицинского отдела" = /obj/item/device/remote_device/chief_medical_officer,
									 "пульт ДУ шлюзами мостика" = /obj/item/device/remote_device/captain,
									 "пульт ДУ шлюзами инженерного отдела" = /obj/item/device/remote_device/chief_engineer,
									 "пульт ДУ шлюзами научного отдела" = /obj/item/device/remote_device/research_director,
									 "пульт ДУ шлюзами отдела снабжения" = /obj/item/device/remote_device/quartermaster,
									 "пульт ДУ шлюзами брига" = /obj/item/device/remote_device/head_of_security,
									 "пульт ДУ шлюзами отделов гражданского назначения" = /obj/item/device/remote_device/head_of_personal,
									 "плюшевый кит капитана" = /obj/item/toy/plushie/space_whale,
									 "Ламарр" = /obj/item/clothing/mask/facehugger/lamarr,
									 "дермал ГСБ" = /obj/item/clothing/accessory/armor/dermal,
									 "феска ГП" = /obj/item/clothing/head/fez
									 )

/datum/objective/gang/steal_lowrisk/select_target()
	var/target = find_and_check_target()
	explanation_text = "Следующей целью будет [target]."
	steal_target = items_to_steal[target]

/datum/objective/gang/steal_lowrisk/proc/find_and_check_target()
	if(global.possible_lowrisk_items_to_steal.len == 2)
		return pick(global.possible_lowrisk_items_to_steal)
	var/objective = pick(items_to_steal)
	global.possible_lowrisk_items_to_steal[objective] = items_to_steal[objective]
	items_to_steal -= objective
	return objective

/datum/objective/gang/steal_lowrisk/New()
	select_target()

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
