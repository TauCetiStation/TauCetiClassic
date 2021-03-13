/datum/role/syndicate
	var/list/uplink_items_bought = list() //migrated from mind, used in GetScoreboard()
	var/total_TC = 0
	var/spent_TC = 0
	var/uplink_uses = 20

/datum/role/syndicate/proc/give_uplink(mob/living/carbon/human/traitor_mob, crystals)
	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/R = locate() //Hide the uplink in a PDA if available, otherwise radio

	if(traitor_mob.client.prefs.uplinklocation == "Headset")
		R = locate(/obj/item/device/radio) in traitor_mob.contents
		if(!R)
			R = locate(/obj/item/device/pda) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a Radio, installing in PDA instead!")
		if (!R)
			to_chat(traitor_mob, "Unfortunately, neither a radio or a PDA relay could be installed.")

	else if(traitor_mob.client.prefs.uplinklocation == "PDA")
		R = locate(/obj/item/device/pda) in traitor_mob.contents
		if(!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a PDA, installing into a Radio instead!")
		if (!R)
			to_chat(traitor_mob, "Unfortunately, neither a radio or a PDA relay could be installed.")

	else if(traitor_mob.client.prefs.uplinklocation == "None")
		to_chat(traitor_mob, "You have elected to not have an AntagCorp portable teleportation relay installed!")
		R = null

	else
		to_chat(traitor_mob, "You have not selected a location for your relay in the antagonist options! Defaulting to PDA!")
		R = locate(/obj/item/device/pda) in traitor_mob.contents
		if (!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a PDA, installing into a Radio instead!")
		if (!R)
			to_chat(traitor_mob, "Unfortunately, neither a radio or a PDA relay could be installed.")

	if (!R)
		. = FALSE
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/obj/item/device/radio/target_radio = R
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/hidden/T = new(R)
			target_radio.hidden_uplink = T
			target_radio.traitor_frequency = freq
			to_chat(traitor_mob, "A portable object teleportation relay has been installed in your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
			total_TC += target_radio.hidden_uplink.uses
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/hidden/T = new(R)
			R.hidden_uplink = T
			var/obj/item/device/pda/P = R
			P.lock_code = pda_pass

			to_chat(traitor_mob, "A portable object teleportation relay has been installed in your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
			total_TC += R.hidden_uplink.uses

/datum/role/syndicate/proc/give_codewords(mob/living/traitor_mob)
	var/code_words = 0
	if(prob(80))
		ASSERT(global.syndicate_code_phrase.len)
		to_chat(traitor_mob, "<u><b>Your employers provided you with the following information on how to identify possible allies:</b></u>")
		var/code_phrase = "<b>Code Phrase</b>: [codewords2string(global.syndicate_code_phrase)]"
		to_chat(traitor_mob, code_phrase)
		traitor_mob.mind.store_memory(code_phrase)
		traitor_mob.mind.syndicate_awareness = SYNDICATE_PHRASES

		code_words += 1

	if(prob(80))
		ASSERT(global.syndicate_code_response.len)
		var/code_response = "<b>Code Response</b>: [codewords2string(global.syndicate_code_response)]"
		to_chat(traitor_mob, code_response)
		traitor_mob.mind.store_memory(code_response)
		traitor_mob.mind.syndicate_awareness = SYNDICATE_RESPONSE

		code_words += 1

	switch(code_words)
		if(0)
			to_chat(traitor_mob, "Unfortunately, the Syndicate did not provide you with a code response.")
		if(1) // half
			to_chat(traitor_mob, "Use the code words, preferably in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
		if(2)
			traitor_mob.mind.syndicate_awareness = SYNDICATE_AWARE
			to_chat(traitor_mob, "Use the code words, preferably in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/role/syndicate/proc/give_intel(mob/living/traitor_mob)
	ASSERT(traitor_mob)
	give_codewords(traitor_mob)
	ASSERT(traitor_mob.mind)

/datum/role/syndicate/proc/equip_traitor(mob/living/carbon/human/traitor_mob)
	if (!istype(traitor_mob))
		return

	if (antag?.assigned_role == "Clown")
		to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
		traitor_mob.mutations.Remove(CLUMSY)

	give_uplink(traitor_mob, uplink_uses)

	var/datum/role/R = traitor_mob.mind.GetRole(TRAITOR)
	if(R)
		for(var/datum/objective/dehead/D in R.objectives.GetObjectives())
			var/obj/item/device/biocan/B = new (traitor_mob.loc)
			var/list/slots = list (
			"backpack" = SLOT_IN_BACKPACK,
			"left hand" = SLOT_L_HAND,
			"right hand" = SLOT_R_HAND,
			)
			var/where = traitor_mob.equip_in_one_of_slots(B, slots)
			traitor_mob.update_icons()
			if (!where)
				to_chat(traitor_mob, "The Syndicate were unfortunately unable to provide you with the brand new can for storing heads.")
			else
				to_chat(traitor_mob, "The biogel-filled can in your [where] will help you to steal you target's head alive and undamaged.")

	give_intel(traitor_mob)

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		to_chat(traitor_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
		traitor_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

/datum/role/syndicate/proc/find_syndicate_uplink(mob/living/carbon/human/human)
	var/list/L = human.get_contents()
	for(var/obj/item/I in L)
		if(I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/role/syndicate/proc/take_uplink(mob/living/carbon/human/human)
	var/obj/item/device/uplink/hidden/H = find_syndicate_uplink(human)
	if(H)
		qdel(H)

/datum/role/syndicate/extraPanelButtons()
	var/dat = ""
	var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink(antag.current)
	if(guplink)
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];telecrystalsSet=1;'>Telecrystals: [guplink.uses](Set telecrystals)</a>"
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a>"
	return dat

/datum/role/syndicate/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["giveuplink"])
		give_uplink(antag.current, 20, src)

	if(href_list["telecrystalsSet"])
		var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink(M.current)
		var/amount = input("What would you like to set their crystal count to?", "Their current count is [guplink.uses]") as null|num
		if(!isnull(amount))
			if(guplink)
				var/diff = amount - guplink.uses
				guplink.uses = amount
				total_TC += diff

	if(href_list["removeuplink"])
		take_uplink(M.current)
		antag.memory = null
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")
