var/global/list/possible_lowrisk_items_to_steal = list()

/datum/objective/gang/steal_lowrisk
    var/obj/item/steal_target
    var/static/items_to_steal = list("captain's spare ID" = /obj/item/weapon/card/id/captains_spare,
									 "nuclear authentication disk" = /obj/item/weapon/disk/nuclear,
									 "chief medical officer's rubber stamp" = /obj/item/weapon/stamp/cmo,
									 "head of personnel's rubber stamp" = /obj/item/weapon/stamp/hop,
									 "captain's rubber stamp" = /obj/item/weapon/stamp/captain,
									 "head of security's rubber stamp" = /obj/item/weapon/stamp/hos,
									 "research director's rubber stamp" = /obj/item/weapon/stamp/rd,
									 "chief engineer's rubber stamp" = /obj/item/weapon/stamp/ce,
									 "quartermaster's rubber stamp" = /obj/item/weapon/stamp/qm,
									 "medical door remote" = /obj/item/device/remote_device/chief_medical_officer,
									 "command door remote" = /obj/item/device/remote_device/captain,
									 "engineering door remote" = /obj/item/device/remote_device/chief_engineer,
									 "research door remote" = /obj/item/device/remote_device/research_director,
									 "supply door remote" = /obj/item/device/remote_device/quartermaster,
									 "security door remote" = /obj/item/device/remote_device/head_of_security,
									 "civillian door remote" = /obj/item/device/remote_device/head_of_personal,
									 "space whale" = /obj/item/toy/plushie/space_whale,
									 "Lamarr" = /obj/item/clothing/mask/facehugger/lamarr,
									 "dermal armour patch" = /obj/item/clothing/accessory/armor/dermal
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
