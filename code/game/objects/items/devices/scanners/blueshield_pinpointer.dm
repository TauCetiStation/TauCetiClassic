// Pinpointer to detect Heads of Staff

/proc/get_heads_dna()
	var/list/heads = list()
	for (var/datum/data/record/R in sortRecord(data_core.general))
		if (R.fields["rank"] in command_positions)
			heads[R.fields["id"]] = R.fields["name"]
	
	var/list/dnas = list()
	for (var/datum/data/record/R in sortRecord(data_core.medical))
		if (R.fields["id"] in heads) // There will be fun thing, if ID's are overlapping
			dnas[R.fields["name"]] = R.fields["b_dna"]
	return dnas

/proc/get_humans_by_dna(var/dna)
	var/list/result = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(!player.dna)
			continue
		if (player.dna.unique_enzymes == dna)
			result += player
	if (result.len == 1)
		result = result[1]
	return result

/obj/item/weapon/pinpointer/heads
	name = "heads of staff pinpointer"
	desc = "A larger version of the normal pinpointer. Includes quantuum connection to the database of the Station Heads of Staff to point to."

	var/_target = null

/obj/item/weapon/pinpointer/heads/process()
	_target = get_humans_by_dna(target_dna)

	if (active && !_target)
		icon_state = "pinonnull"
		return
	
	if (islist(_target))
		target = get_closest_atom(/mob/living/carbon/human, _target, src)
	else
		target = _target

	. = ..()

/obj/item/weapon/pinpointer/heads/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Target"
	set src in view(1)

	active = FALSE
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	_target = null

	var/list/heads_dna = get_heads_dna()
	if (!heads_dna.len)
		to_chat(usr, "There is no Heads of staff on the station!")
		return
	var/target_head = tgui_input_list(usr, "Head to point to", "Target selection", heads_dna)

	if (!target_head)
		return
	var/target_dna = heads_dna[target_head]
	to_chat(usr, "You set the pinpointer to locate [target_head] ([target_dna])")

	return attack_self(usr)