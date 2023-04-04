/datum/objective/gang/steal_lowrisk
	var/obj/item_to_steal
	
/datum/objective/gang/steal_lowrisk/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue
		var/list/items_to_check = M.GetAllContents()
		var/item_found = locate(item_to_steal) in items_to_check
		if(item_found)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

var/list/items_to_steal = list("запасная карта капитана"=/obj/item/weapon/card/id/captains_spare,
							   "диск от ядерной боеголовки"=/obj/item/weapon/disk/nuclear,
							   "печать СМО"=/obj/item/weapon/stamp/cmo,
							   "печать ГП"=/obj/item/weapon/stamp/hop,
							   "печать капитана"=/obj/item/weapon/stamp/captain,
							   "печать ГСБ"=/obj/item/weapon/stamp/hos,
							   "печать ДИР"=/obj/item/weapon/stamp/rd,
							   "печать СИ"=/obj/item/weapon/stamp/ce,
							   "печать КМ"=/obj/item/weapon/stamp/qm,
							   "медицинский пульт ДУ"=/obj/item/device/remote_device/chief_medical_officer,
							   "капитанский пульт ДУ"=/obj/item/device/remote_device/captain,
							   "инженерный пульт ДУ"=/obj/item/device/remote_device/chief_engineer,
							   "научный пульт ДУ"=/obj/item/device/remote_device/research_director,
							   "снабжающий пульт ДУ"=/obj/item/device/remote_device/quartermaster,
							   "офицерский пульт ДУ"=/obj/item/device/remote_device/head_of_security,
							   "гражданский пульт ДУ"=/obj/item/device/remote_device/head_of_personal,
							   "плюшевый кит капитана"=/obj/item/toy/plushie/space_whale,
							   "Ламарр"=/obj/item/clothing/mask/facehugger/lamarr,
							   "дермал ГСБ"=/obj/item/clothing/accessory/armor/dermal,
							   "феска ГП"=/obj/item/clothing/head/fez
							  )

var/list/todays_steal_objectives = list(pick(items_to_steal),pick(items_to_steal),pick(items_to_steal))

/proc/get_steal_objective()
	var/datum/objective/gang/steal_lowrisk/S = new
	var/explanation = pick(todays_steal_objectives)
	S.explanation_text = "Следующей целью станет [explanation]."
	S.item_to_steal = items_to_steal[explanation]
	return S
