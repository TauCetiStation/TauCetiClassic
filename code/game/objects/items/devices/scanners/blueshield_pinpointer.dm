// Pinpointer to detect Heads of Staff

/proc/get_jobs_dna(list/required_positions)
	var/list/players = list()
	for (var/datum/data/record/R in data_core.general)
		if (R.fields["rank"] in required_positions)
			players[R.fields["id"]] = R.fields["name"]
	
	var/list/dnas = list()
	for (var/datum/data/record/R in data_core.medical)
		if (R.fields["id"] in players) // There will be fun thing, if ID's are overlapping
			dnas[players[R.fields["id"]]] = R.fields["b_dna"] // If Head is IPC there will be ""
	return dnas

/proc/get_humans_by_dna(dna)
	var/list/result = list()
	for(var/mob/living/carbon/human/player in human_list)
		if (!player.dna)
			continue
		if (!player.dna.unique_enzymes)
			continue // IPC will produce "?" on pinpointer, because there is no DNA
		if (player.dna.unique_enzymes == dna)
			result += player
	return result

/obj/item/weapon/pinpointer/heads
	name = "heads of staff pinpointer"
	desc = "A larger version of the normal pinpointer. Includes quantuum connection to the database of the Station Heads of Staff to point to."

	var/target_dna = null

/obj/item/weapon/pinpointer/heads/process()
	if (!active)
		STOP_PROCESSING(SSobj, src) // Just to be sure
		return

	if (!target_dna)
		icon_state = "pinonnull"
		return

	var/list/_target = null
	if (target_dna)
		_target = get_humans_by_dna(target_dna)
	
	if (active && !_target.len)
		icon_state = "pinonnull"
		return
	
	if (_target.len > 1)
		target = get_closest_atom(/mob/living/carbon/human, _target, src)
	else
		target = pick(_target)

	return ..()

/obj/item/weapon/pinpointer/heads/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Target"
	set src in view(1)

	active = FALSE
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"

	var/list/heads_dna = get_jobs_dna(heads_positions + "Internal Affairs Agent")
	if (!heads_dna.len)
		to_chat(usr, "There is no command staff on the station!")
		return
	var/target_head = tgui_input_list(usr, "Head to point to", "Target selection", heads_dna)

	if (!target_head)
		return
	target_dna = heads_dna[target_head]
	to_chat(usr, "You set the pinpointer to locate [target_head]")

	return attack_self(usr)
