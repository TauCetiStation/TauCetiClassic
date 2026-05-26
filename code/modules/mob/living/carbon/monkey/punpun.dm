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

/mob/living/carbon/monkey/punpun/atom_init()
	AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(Write_Memory)), CALLBACK(src, PROC_REF(Read_Memory)), "/mobs/punpun", list(
		"ancestor_name" = list("field_type" = "string", "max_length" = 150, "can_be_null" = TRUE),
		"ancestor_chain" = list("field_type" = "int", "min_num" = 1),
		"relic_mask" = list("field_type" = "type", "in_list" = subtypesof(/obj/item/clothing/mask) + null, "can_be_null" = TRUE),
	), list(COMSIG_MOB_DIED), CALLBACK(src, PROC_REF(Write_Death)))

	name = pick(pet_monkey_names)
	gender = pick(MALE, FEMALE)

	. = ..()

/mob/living/carbon/monkey/punpun/proc/Read_Memory(save_data)
	ancestor_name = save_data["ancestor_name"]
	ancestor_chain = save_data["ancestor_chain"]

	var/mask_type = save_data["relic_mask"]
	if(mask_type)
		var/obj/item/mask = new mask_type
		equip_to_slot_or_del(mask, SLOT_WEAR_MASK)

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

/mob/living/carbon/monkey/punpun/proc/Write_Death(gibbed)
	return Write_Memory(TRUE, gibbed)

/mob/living/carbon/monkey/punpun/proc/Write_Memory(dead, gibbed)
	var/list/data = list(
		"ancestor_name" = null,
		"ancestor_chain" = ancestor_chain,
		"relic_mask" = null,
	)

	if(gibbed)
		data["ancestor_chain"] = 1
		return data

	if(dead && istext(ancestor_name) && isnum(ancestor_chain))
		data["ancestor_name"] = ancestor_name
		data["ancestor_chain"] = ancestor_chain + 1
	if(!ancestor_name && istext(name))	//new monkey name this round
		data["ancestor_name"] = name
	if(wear_mask && isitem(wear_mask))
		data["relic_mask"] = wear_mask.type
	else
		data["relic_mask"] = null

	return data
