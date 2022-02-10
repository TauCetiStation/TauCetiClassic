/datum/component/gamemode/syndicate
	// Uplink
	var/list/uplink_items_bought = list() //migrated from mind, used in GetScoreboard()
	var/total_TC = 0
	var/spent_TC = 0
	var/uplink_uses

	// Dont uplink
	var/syndicate_awareness = SYNDICATE_UNAWARE

/datum/component/gamemode/syndicate/Initialize(crystals)
	..()
	uplink_uses = crystals

/datum/component/gamemode/syndicate/Destroy()
	return ..()

/datum/component/gamemode/syndicate/proc/get_current()
	var/datum/role/role = parent
	var/mob/living/carbon/human/traitor_mob = role.antag.current
	if(!traitor_mob)
		return

	return traitor_mob

/datum/component/gamemode/syndicate/proc/give_uplink()
	var/mob/traitor_mob = get_current()
	if(!traitor_mob)
		return

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/R //Hide the uplink in a PDA if available, otherwise radio

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

	else if(traitor_mob.client.prefs.uplinklocation == "Intercom")
		var/list/station_intercom_list = list()
		for(var/obj/item/device/radio/intercom/I as anything in intercom_list)
			if(is_station_level(I.z))
				station_intercom_list += I

		if(station_intercom_list.len)
			R = pick(station_intercom_list)
		if(!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate suitable Intercom, installing into a Radio instead!")
		if (!R)
			R = locate(/obj/item/device/pda) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a Radio, installing in PDA instead!")
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
		T.uses = uplink_uses
		target_radio.hidden_uplink = T
		target_radio.traitor_frequency = freq
		if(istype(target_radio, /obj/item/device/radio/intercom))
			to_chat(traitor_mob, "A portable object teleportation relay has been installed into an [R.name] intercom at [get_area(R)]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [get_area(R)].")
			target_radio.hidden_uplink.uses += 5
		else
			to_chat(traitor_mob, "A portable object teleportation relay has been installed in your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		total_TC += target_radio.hidden_uplink.uses

	else if (istype(R, /obj/item/device/pda))
		// generate a passcode if the uplink is hidden in a PDA
		var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"
		var/obj/item/device/uplink/hidden/T = new(R)
		T.uses = uplink_uses
		R.hidden_uplink = T
		var/obj/item/device/pda/P = R
		P.lock_code = pda_pass
		to_chat(traitor_mob, "A portable object teleportation relay has been installed in your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
		traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
		total_TC += R.hidden_uplink.uses

/datum/component/gamemode/syndicate/proc/give_codewords()
	var/mob/traitor_mob = get_current()
	if(!traitor_mob)
		return

	var/code_words = 0
	if(prob(80))
		ASSERT(global.syndicate_code_phrase.len)
		to_chat(traitor_mob, "<u><b>Your employers provided you with the following information on how to identify possible allies:</b></u>")
		var/code_phrase = "<b>Code Phrase</b>: [codewords2string(global.syndicate_code_phrase)]"
		to_chat(traitor_mob, code_phrase)
		traitor_mob.mind.store_memory(code_phrase)
		syndicate_awareness = SYNDICATE_PHRASES

		code_words += 1

	if(prob(80))
		ASSERT(global.syndicate_code_response.len)
		var/code_response = "<b>Code Response</b>: [codewords2string(global.syndicate_code_response)]"
		to_chat(traitor_mob, code_response)
		traitor_mob.mind.store_memory(code_response)
		syndicate_awareness = SYNDICATE_RESPONSE

		code_words += 1

	switch(code_words)
		if(0)
			to_chat(traitor_mob, "Unfortunately, the Syndicate did not provide you with a code response.")
		if(1) // half
			to_chat(traitor_mob, "Use the code words, preferably in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
		if(2)
			syndicate_awareness = SYNDICATE_AWARE
			to_chat(traitor_mob, "Use the code words, preferably in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/component/gamemode/syndicate/proc/give_intel()
	var/mob/traitor_mob = get_current()
	if(!traitor_mob)
		return

	ASSERT(traitor_mob)
	give_codewords(traitor_mob)
	ASSERT(traitor_mob.mind)

/datum/component/gamemode/syndicate/proc/equip_traitor()
	var/mob/mob = get_current()
	if(!mob)
		return

	give_intel()

	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/traitor_mob = mob

	if (traitor_mob.mind?.assigned_role == "Clown")
		to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
		traitor_mob.mutations.Remove(CLUMSY)

	var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink(traitor_mob)
	if(!guplink)
		give_uplink()
	else
		guplink.uses = uplink_uses
		total_TC = uplink_uses

	var/datum/role/R = parent
	for(var/datum/objective/target/dehead/D in R.objectives.GetObjectives())
		var/obj/item/device/biocan/B = new (traitor_mob.loc)
		var/list/slots = list(
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

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		to_chat(traitor_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
		traitor_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

/datum/component/gamemode/syndicate/proc/take_uplink()
	var/mob/living/carbon/human/traitor_mob = get_current()
	if(!traitor_mob || !istype(traitor_mob))
		return

	var/obj/item/I = find_syndicate_uplink(traitor_mob)
	if(I?.hidden_uplink)
		QDEL_NULL(I.hidden_uplink)

/datum/component/gamemode/syndicate/OnPostSetup(datum/source, laterole)
	equip_traitor()

/datum/component/gamemode/syndicate/GetScoreboard(datum/source)
	if(total_TC)
		if(spent_TC)
			. += "<br><b>TC Remaining:</b> [total_TC - spent_TC]/[total_TC]"
			. += "<br><b>The tools used by the traitor were:</b>"
			for(var/entry in uplink_items_bought)
				. += "<br>[entry]"
		else
			. += "<br>The traitor was a smooth operator this round (did not purchase any uplink items)."

/datum/component/gamemode/syndicate/extraPanelButtons(datum/source)
	var/datum/role/role = parent
	var/mob/living/carbon/human/traitor_mob = get_current()
	if(!traitor_mob || !istype(traitor_mob))
		return

	var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink(traitor_mob)
	if(guplink)
		. += " - <a href='?src=\ref[role];mind=\ref[role.antag];role=\ref[src];telecrystalsSet=1;'>Telecrystals: [guplink.uses](Set telecrystals)</a>"
		. += " - <a href='?src=\ref[role];mind=\ref[role.antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a>"
	else
		. = " - <a href='?src=\ref[role];mind=\ref[role.antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a>"

/datum/component/gamemode/syndicate/RoleTopic(datum/source, href, href_list, datum/mind/M, admin_auth)
	if(!M || !M.current)
		return

	if(href_list["giveuplink"])
		give_uplink()

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
		var/datum/role/role = parent
		role.antag.memory = null
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")
