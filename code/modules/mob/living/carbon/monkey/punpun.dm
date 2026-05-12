/mob/living/carbon/monkey/punpun //except for a few special persistence features, pun pun is just a normal monkey
	name = "Pun Pun" //C A N O N
	icon_state = "punpun1"
	var/ancestor_name
	var/ancestor_chain = 1
	var/relic_hat	//Note: these two are paths
	var/relic_mask
	var/list/pet_monkey_names = list("Pun Pun", "Bubbles", "Mojo", "George", "Darwin", "Aldo", "Caeser", "Kanzi", "Kong", "Terk", "Grodd", "Mala", "Bojangles", "Coco", "Able", "Baker", "Scatter", "Norbit", "Travis")
	var/list/rare_pet_monkey_names = list("Professor Bobo", "Deempisi's Revenge", "Furious George", "King Louie", "Dr. Zaius", "Jimmy Rustles", "Dinner", "Lanky")
	holder_type = /obj/item/weapon/holder/monkey/punpun
	var/datum/component/continuity_object/Continuity

/mob/living/carbon/monkey/punpun/atom_init()
	Continuity = AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(Write_Memory)), CALLBACK(src, PROC_REF(Read_Memory)))
	. = ..()

/mob/living/carbon/monkey/punpun/death(gibbed)
	if(gibbed && Continuity)
		Continuity.preemptive_save(TRUE, gibbed)
		Continuity = null
	..()

/mob/living/carbon/monkey/punpun/proc/Read_Memory(save_data)
	var/list/data = params2list(save_data)
	if(data.len)
		ancestor_name = data["ancestor_name"]
		ancestor_chain = text2num(data["ancestor_chain"])
		relic_mask = text2path(data["relic_mask"])

	if(relic_mask)
		equip_to_slot_or_del(new relic_mask, SLOT_WEAR_MASK)

	if(ancestor_name)
		name = ancestor_name
		if(ancestor_chain > 1)
			name += " [num2roman(ancestor_chain)]"
	else
		if(prob(5))
			name = pick(rare_pet_monkey_names)
		else
			name = pick(pet_monkey_names)
		gender = pick(MALE, FEMALE)

/mob/living/carbon/monkey/punpun/proc/Write_Memory(dead, gibbed)
	var/list/data = list(
		"ancestor_name" = "",
		"ancestor_chain" = "",
		"relic_mask" = "",
	)
	if(gibbed)
		data["ancestor_name"] = null
		data["ancestor_chain"] = "1"
		data["relic_mask"] = null
		return list2params(data)

	if(dead && istext(ancestor_name) && isnum(ancestor_chain))
		data["ancestor_name"] = ancestor_name
		data["ancestor_chain"] = "[ancestor_chain + 1]"
	if(!ancestor_name && istext(name))	//new monkey name this round
		data["ancestor_name"] = name
	if(wear_mask && istype(wear_mask, wear_mask.type) && !(wear_mask.flags_2 & NO_CONTINUITY))
		data["relic_mask"] = wear_mask.type
	else
		data["relic_mask"] = null

	return list2params(data)
