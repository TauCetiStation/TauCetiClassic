#define MAX_WAITING_TIME 36

/obj/effect/overlay/item_illusion
	var/obj/my_fake_type
	var/image/fake_icon
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/religion_rites/pedestals
	// The number of all items on pedestals must be longer than the length of ritual_invocations
	// otherwise there will be no phrases
	ritual_invocations = null
	can_talismaned = FALSE

	// One element must contain the type and number of items for one pedestal. types_by_count
	var/list/rules = list()

	var/search_radius_of_pedestals = 3

	// Used in rite, dont fill it
	// All pedestals around the altar
	var/list/pedestals
	// pedestal = list(type = count_of_type)
	var/list/involved_pedestals = list()
	var/items_to_spawn = 0
	var/item_stage = 0
	var/phrase_indx = 1
	var/phrase_frequency = 0
	var/waiting_time = 0

/datum/religion_rites/pedestals/New()
	for(var/type in rules)
		items_to_spawn += rules[type]

	if(ritual_invocations)
		phrase_frequency = clamp(round(items_to_spawn / ritual_invocations.len), ritual_invocations.len, items_to_spawn)

/datum/religion_rites/pedestals/get_count_steps()
	return rules.len

/datum/religion_rites/pedestals/can_start(mob/user, obj/structure/altar_of_gods/AOG)
	if(!rules || !rules.len)
		return FALSE

	if(pedestals.len < rules.len)
		if(user)
			to_chat(user, "<span class='warning'>You need more [rules.len - pedestals.len] pedestals.</span>")
		return FALSE

	for(var/obj/structure/pedestal/cult/P in involved_pedestals)
		if(P.last_turf != get_turf(P))
			if(user)
				to_chat(user, "<span class='warning'>The pedestal changed its first position.</span>")
			return FALSE

	return TRUE

/datum/religion_rites/pedestals/on_chosen(mob/user, obj/structure/altar_of_gods/AOG)
	..()

	init_pedestals(AOG)

	if(pedestals.len < rules.len)
		to_chat(user, "<span class='warning'>You need more [rules.len - pedestals.len] pedestals.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/pedestals/can_invocate(mob/user, obj/structure/altar_of_gods/AOG)
	if(!AOG || !get_turf(AOG)) // Due to the working beam, it will not be able to properly delete at this stage
		if(user)
			to_chat(user, "<span class='warning'>Алтарь исчез.</span>")
		return FALSE
	if(waiting_time >= MAX_WAITING_TIME)
		if(user)
			to_chat(user, "<span class='warning'>Ритуал длится слишком долго.</span>")
		return FALSE
	if(!AOG.anchored)
		if(user)
			to_chat(user, "<span class='warning'>Алтарь больше не закреплен на месте.</span>")
		return FALSE
	if(!involved_pedestals.len)
		if(user)
			to_chat(user, "<span class='warning'>Все пьедесталы исчезли.</span>")
		return FALSE
	for(var/obj/structure/P in involved_pedestals)
		if(!P.anchored)
			if(user)
				to_chat(user, "<span class='warning'>Пилоны больше не закреплены на месте.</span>")
			return FALSE
	if(!can_start(user, AOG))
		return FALSE
	return TRUE

/datum/religion_rites/pedestals/pre_start(mob/user, obj/structure/altar_of_gods/AOG)
	var/rules_indx = 1
	var/for_step = pedestals.len/rules.len
	for(var/i in 1 to pedestals.len step for_step)
		new /obj/effect/temp_visual/cult/sparks(get_turf(pedestals[i]))
		involved_pedestals[pedestals[i]] = list(rules[rules_indx] = rules[rules[rules_indx]])
		var/obj/structure/pedestal/cult/P = pedestals[i]
		P.my_rite = src
		P.create_illusions(rules[rules_indx], rules[rules[rules_indx]])
		rules_indx += 1

/datum/religion_rites/pedestals/rite_step(mob/user, obj/structure/altar_of_gods/AOG, current_stage)
	var/obj/structure/pedestal/cult/P = involved_pedestals[current_stage]
	P.create_holy_outline("#c50404")
	for(var/ill in P.lying_illusions)
		item_stage += 1
		waiting_time = 0
		var/datum/beam/B = AOG.Beam(ill, "drainvortex", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 2 SECONDS)
		sleep(ritual_length / items_to_spawn)
		var/obj/item/item = P.lying_illusions[ill]
		while(!item && P && can_invocate(null, AOG, FALSE)) // waiting item with antilag
			item = P.lying_illusions[ill]
			stoplag(5 SECONDS)
			waiting_time += 1

		if(!can_invocate(null, AOG, FALSE)) // null because i dont want message to be sent to user
			break

		if(ritual_invocations && (item_stage % phrase_frequency == 1))
			for(var/mob/M as anything in AOG.get_members_around())
				M.say(ritual_invocations[phrase_indx])
			phrase_indx += 1

		P.lying_items -= item
		P.lying_illusions.Remove(ill)
		qdel(item)
		qdel(ill)
		B.End()

/datum/religion_rites/pedestals/end(mob/user, obj/structure/altar_of_gods/AOG)
	if(invoke_msg)
		user.say(invoke_msg)

/datum/religion_rites/pedestals/proc/init_pedestals(obj/structure/altar_of_gods/AOG)
	pedestals = list()
	for(var/obj/structure/pedestal/cult/P in spiral_range(search_radius_of_pedestals, AOG))
		if(P.my_rite || !P.anchored)
			continue
		pedestals += P
		P.last_turf = get_turf(P)

/datum/religion_rites/pedestals/reset_rite()
	for(var/obj/structure/pedestal/cult/P in involved_pedestals)
		P.clear_items()
		P.del_holy_outline()
		P.my_rite = null

	involved_pedestals = list()

	item_stage = initial(item_stage)
	phrase_indx = initial(phrase_indx)
	waiting_time = initial(waiting_time)

#undef MAX_WAITING_TIME
