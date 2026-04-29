#define LIMIT_FOR_FAMILY 3

/datum/family
	var/desc = ""

/datum/family/proc/check_family_members(mob/living/carbon/human/target)
	var/couter = 0
	var/surename = get_surename(target)
	if(!global.family.len)
		return TRUE
	for(var/i in global.family)
		var/target_surename = get_surename(i)
		if(target_surename == surename)
			couter += 1
	if(couter >= LIMIT_FOR_FAMILY)
		return FALSE
	else
		return TRUE

/datum/family/proc/add_family(mob/living/carbon/human/H)
	if(!H.client.prefs.family_status)
		return
	get_suitable_member(H)

/datum/family/proc/get_surename(mob/living/carbon/human/target)
	var/surename = ""
	if(target.species == UNATHI)
		surename = replacetext(target.real_name, regex(@".\w+$"), surename)
	else
		surename = replacetext(target.real_name, regex(@"^\w+."), surename)
	return surename

/datum/family/proc/take_member(mob/living/carbon/human/H, mob/living/carbon/human/target)
	var/new_name = ""
	var/surename = get_surename(target)
	if(target.species == UNATHI)
		new_name = replacetext(H.real_name, regex(@"^\w+"), surename)
		H.real_name = new_name
	else
		new_name = replacetext(H.real_name, regex(@"\w+$"), surename)
		H.real_name = new_name

	if(istype(H.wear_id, /obj/item/weapon/card/id)) // check id card
		var/obj/item/weapon/card/id/wear_id = H.wear_id
		wear_id.assign(new_name)

		var/obj/item/device/pda/pda = locate() in H // find closest pda
		if(pda)
			pda.ownjob = wear_id.assignment
			pda.assign(new_name)
	to_chat(H, "<span class='warning'>Теперь Вы член семьи [surename]!</span>")
	to_chat(target, "<span class='warning'>Теперь [H.real_name] член Вышей семьи!</span>")
	global.family += H
	if(!global.family.Find(target))
		global.family += (target)

/datum/family/proc/get_suitable_member(mob/living/carbon/human/H)
	var/list/pos_players = global.people_who_want_find_family.Copy()
	pos_players -= H

	var/mob/living/carbon/human/target = null

	while(target == null && length(pos_players) > 0)
		var/mob/living/carbon/human/potential_target = pick(pos_players)
		pos_players -= potential_target
		// AI and borgs.
		if(!istype(potential_target))
			continue
		// This shouldn't be able to happen, but to prevent runtimes...
		if(!potential_target.mind)
			continue
		// While funny, please no.
		if(isanyantag(potential_target))
			continue
		if(!check_family_members(potential_target))
			continue
		// Hm.
		var/datum/species/S = all_species[potential_target.get_species()]
		if(S == DIONA || S == IPC || S == VOX)
			continue
		if(H.species != potential_target.species)
			continue
		target = potential_target

	if(!target)
		to_chat(H, "<span class='warning'>Нет потенциальных членов семьи!</span>")
		return
	else
		take_member(H, target)

#undef LIMIT_FOR_FAMILY
