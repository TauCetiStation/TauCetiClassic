/datum/component/gamemode/syndicate
	// Uplink
	var/list/uplink_items_bought = list() //migrated from mind, used in GetScoreboard()
	var/total_TC = 0
	var/spent_TC = 0
	var/uplink_uses
	var/uplink_type = "traitor"

	// Dont uplink
	var/syndicate_awareness = SYNDICATE_UNAWARE
	var/list/datum/stat/uplink_purchase/uplink_purchases = list()

/datum/component/gamemode/syndicate/Initialize(crystals, type)
	..()
	uplink_uses = crystals
	uplink_type = type


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
			to_chat(traitor_mob, "Гарнитура не обнаружена, установка портативного телепортационного реле AntagCorp в КПК!")
		if (!R)
			to_chat(traitor_mob, "К сожалению, не удалось установить портативное телепортационное реле AntagCorp ни в гарнитуру, ни в КПК.")

	else if(traitor_mob.client.prefs.uplinklocation == "PDA")
		R = locate(/obj/item/device/pda) in traitor_mob.contents
		if(!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "КПК не обнаружен, установка портативного телепортационного реле AntagCorp в гарнитуру!")
		if (!R)
			to_chat(traitor_mob, "К сожалению, не удалось установить портативное телепортационное реле AntagCorp ни в гарнитуру, ни в КПК.")

	else if(traitor_mob.client.prefs.uplinklocation == "Intercom")
		var/list/station_intercom_list = list()
		for(var/obj/item/device/radio/intercom/I as anything in intercom_list)
			if(is_station_level(I.z))
				station_intercom_list += I

		if(station_intercom_list.len)
			R = pick(station_intercom_list)
		if(!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "Не обнаружено подходящего интеркома внутренней связи станции, установка портативного телепортационного реле AntagCorp в гарнитуру!")
		if (!R)
			R = locate(/obj/item/device/pda) in traitor_mob.contents
			to_chat(traitor_mob, "Гарнитура не обнаружена, установка портативного телепортационного реле AntagCorp в КПК!")
		if (!R)
			to_chat(traitor_mob, "К сожалению, не удалось установить портативное телепортационное реле AntagCorp ни в гарнитуру, ни в КПК.")

	else if(traitor_mob.client.prefs.uplinklocation == "None")
		to_chat(traitor_mob, "Вы отказались от установки портативного телепортационного реле AntagCorp! Удачи.")
		R = null

	else
		to_chat(traitor_mob, "Вы не указали место установки портативного телепортационного реле AntagCorp в настройках антагонистов (перед началом раунда, зайдите в Setup, далее во вкладку Roles и нажмите на \"PDA\", чтобы вам был выдан список где может быть установлен Аплинк)! По умолчанию в КПК!")
		R = locate(/obj/item/device/pda) in traitor_mob.contents
		if (!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "КПК не обнаружен, установка портативного телепортационного реле AntagCorp в гарнитуру!")
		if (!R)
			to_chat(traitor_mob, "К сожалению, не удалось установить портативное телепортационное реле AntagCorp ни в гарнитуру, ни в КПК.")

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
			to_chat(traitor_mob, "Портативное телепортационное реле, сокращённо - Аплинк, было установлено в [R.name] внутренней связи станции в районе [get_area(R)]. Просто переключитесь на нужную частоту [format_frequency(freq)] для получения доступа к скрытому функционалу.")
			traitor_mob.mind.store_memory("<B>Радиочастота:</B> [format_frequency(freq)] ([R.name] [get_area(R)].")
			target_radio.hidden_uplink.uses += 5
		else
			to_chat(traitor_mob, "Портативное телепортационное реле, сокращённо - Аплинк, было установлено в ваш [R.name] [loc]. Просто переключитесь на нужную частоту [format_frequency(freq)] для получения доступа к скрытому функционалу.")
			traitor_mob.mind.store_memory("<B>Радиочастота:</B> [format_frequency(freq)] ([R.name] [loc]).")
		total_TC += target_radio.hidden_uplink.uses
		target_radio.hidden_uplink.uplink_type = uplink_type

	else if (istype(R, /obj/item/device/pda))
		// generate a passcode if the uplink is hidden in a PDA
		var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"
		var/obj/item/device/uplink/hidden/T = new(R)
		T.uses = uplink_uses
		R.hidden_uplink = T
		var/obj/item/device/pda/P = R
		P.lock_code = pda_pass
		to_chat(traitor_mob, "Портативное телепортационное реле, сокращённо - Аплинк, было установлено в ваш [R.name] [loc]. Просто введите код выданный вам ранее \"[pda_pass]\", зайдите в настройки вашего КПК, а именно в изменения вашего рингтона, вместо \"beep\" введите тот самый код для получения доступа к скрытому функционалу.")
		traitor_mob.mind.store_memory("<B>Код для Аплинка:</B> [pda_pass] ([R.name] [loc]).")
		total_TC += R.hidden_uplink.uses
		R.hidden_uplink.uplink_type = uplink_type

	R.hidden_uplink.extra_purchasable += create_uplink_sales(rand(2,3), "Discounts", TRUE, get_uplink_items(R.hidden_uplink))

/datum/component/gamemode/syndicate/proc/give_codewords()
	var/mob/traitor_mob = get_current()
	if(!traitor_mob)
		return

	var/code_words = 0
	if(prob(80))
		ASSERT(global.syndicate_code_phrase.len)
		to_chat(traitor_mob, "<u><b>Ваш работодатель позаботился, чтобы вам была предоставлена информация для связи с остальными агентами, если таковы будут обнаружены:</b></u>")
		var/code_phrase = "<b>Кодовая фраза</b>: [codewords2string(global.syndicate_code_phrase)]"
		to_chat(traitor_mob, code_phrase)
		traitor_mob.mind.store_memory(code_phrase)
		syndicate_awareness = SYNDICATE_PHRASES

		code_words += 1

	if(prob(80))
		ASSERT(global.syndicate_code_response.len)
		var/code_response = "<b>Ответы для кодовой фразы</b>: [codewords2string(global.syndicate_code_response)]"
		to_chat(traitor_mob, code_response)
		traitor_mob.mind.store_memory(code_response)
		syndicate_awareness = SYNDICATE_RESPONSE

		code_words += 1

	switch(code_words)
		if(0)
			to_chat(traitor_mob, "К сожалению, Синдикат не предоставил вам кодовые фразы для связи с другими агентами.")
		if(1) // half
			to_chat(traitor_mob, "Воспользуйтесь кодовыми словами в указанном порядке для идентификации других агентов во время разговора. Помните, что каждый может оказаться врагом.")
		if(2)
			syndicate_awareness = SYNDICATE_AWARE
			to_chat(traitor_mob, "Воспользуйтесь кодовыми словами в указанном порядке для идентификации других агентов во время разговора. Помните, что каждый может оказаться врагом.")

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
		to_chat(traitor_mob, "Ваши специальные тренировки позволили вам преодолеть клоунскую неуклюжесть, что позволит вам без вреда для себя применять любое вооружение.")
		REMOVE_TRAIT(traitor_mob, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)

	if(uplink_uses > 0)
		var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink(traitor_mob)
		if(!guplink)
			give_uplink()
		else
			guplink.uses = uplink_uses
			total_TC = uplink_uses

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		to_chat(traitor_mob, "Надежные источники сообщают, что [M.real_name], возможно, захочет помочь вам достигнуть целей. Если вам нужна помощь, то можете обратится к данному сотруднику.")
		traitor_mob.mind.store_memory("<b>Потенциальный соратник</b>: [M.real_name]")

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
