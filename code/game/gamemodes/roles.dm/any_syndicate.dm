/datum/role/syndicate
	var/list/uplink_items_bought = list() //migrated from mind, used in GetScoreboard()
	var/total_TC = 0
	var/spent_TC = 0

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

/datum/role/syndicate/extraPanelButtons()
	var/dat = ""
	var/obj/item/device/uplink/hidden/guplink = antag.find_syndicate_uplink()
	if(guplink)
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];telecrystalsSet=1;'>Telecrystals: [guplink.uses](Set telecrystals)</a><br>"
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a><br>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a><br>"
	return dat

/datum/role/syndicate/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["giveuplink"])
		give_uplink(antag.current, 20, src)

	if(href_list["telecrystalsSet"])
		var/obj/item/device/uplink/hidden/guplink = M.find_syndicate_uplink()
		var/amount = input("What would you like to set their crystal count to?", "Their current count is [guplink.uses]") as null|num
		if(!isnull(amount))
			if(guplink)
				var/diff = amount - guplink.uses
				guplink.uses = amount
				total_TC += diff

	if(href_list["removeuplink"])
		M.take_uplink()
		antag.memory = null
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")
