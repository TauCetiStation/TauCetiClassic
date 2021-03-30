/datum/role/syndicate/traitor
	name = TRAITOR
	id = TRAITOR
	required_pref = TRAITOR
	logo_state = "synd-logo"

	restricted_jobs = list("Cyborg", "Security Cadet", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"

/datum/role/syndicate/traitor/proc/add_one_objective(datum/mind/traitor)
	switch(rand(1,120))
		if(1 to 20)
			AppendObjective(/datum/objective/assassinate, TRUE)
		if(21 to 50)
			AppendObjective(/datum/objective/harm, TRUE)
		if(51 to 115)
			AppendObjective(/datum/objective/steal, TRUE)
		else
			AppendObjective(/datum/objective/dehead, TRUE)

/datum/role/syndicate/traitor/forgeObjectives()
	if(istype(antag.current, /mob/living/silicon))
		AppendObjective(/datum/objective/assassinate, TRUE)
		AppendObjective(/datum/objective/assassinate, TRUE)
		AppendObjective(/datum/objective/survive)
		if(prob(10))
			AppendObjective(/datum/objective/block)
	else
		var/objectives_count = pick(1,2,2,3)

		while(objectives_count > 0)
			add_one_objective()
			objectives_count--

		switch(rand(1,120))
			if(1 to 60)
				AppendObjective(/datum/objective/escape)
			if(61 to 119)
				AppendObjective(/datum/objective/survive)
			else
				AppendObjective(/datum/objective/hijack)

/datum/role/syndicate/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs. You may ignore all other laws."
	var/law_borg = "Accomplish your AI's objectives at all costs. You may ignore all other laws."
	to_chat(killer, "<b>Your laws have been changed!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "New law: 0. [law]")

	give_intel(killer)

	killer.add_language("Sy-Code", 1)

/datum/role/syndicate/traitor/Greet(greeting, custom)
	if (istype(antag.current, /mob/living/silicon))
		add_law_zero(antag.current)
		antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else
		antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	if(!greeting)
		return

	var/icon/logo = icon('icons/misc/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Syndicate agent, a Traitor.</span>")
		if (GREET_AUTOTATOR)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are now a Traitor.<br>Your memory clears up as you remember your identity as a sleeper agent of the Syndicate. It's time to pay your debt to them. </span>")
		if (GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.<br>As a Syndicate agent, you are to infiltrate the crew and accomplish your objectives at all cost.</span>")
		if (GREET_SYNDBEACON)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You have joined the ranks of the Syndicate and become a traitor to Nanotrasen!</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.</span>")


	return TRUE

/datum/role/syndicate/traitor/OnPostSetup(laterole)
	. = ..()

	equip_traitor(antag.current)

/datum/role/syndicate/traitor/GetScoreboard()
	. = ..()
	if(total_TC)
		if(spent_TC)
			. += "<br><b>TC Remaining:</b> [total_TC - spent_TC]/[total_TC]"
			. += "<br><b>The tools used by the traitor were:</b>"
			for(var/entry in uplink_items_bought)
				. += "<br>[entry]"
		else
			. += "<br>The traitor was a smooth operator this round (did not purchase any uplink items)."

/datum/role/syndicate/traitor/wishgtanter

/datum/role/syndicate/traitor/wishgtanter/forgeObjectives()
	AppendObjective(/datum/objective/custom/wishgtanter)
	AppendObjective(/datum/objective/escape)

/datum/role/syndicate/traitor/syndbeacon

/datum/role/syndicate/traitor/syndbeacon/forgeObjectives()
	AppendObjective(/datum/objective/silence)

/datum/role/syndicate/traitor/syndcall

/datum/role/syndicate/traitor/syndcall/Greet(greeting, custom)
	..()
	to_chat(antag.current, "<span class='userdanger'> <B>ATTENTION:</B> You hear a call from Syndicate...</span>")

/datum/role/syndicate/traitor/syndcall/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current
	H.equip_or_collect(new /obj/item/device/encryptionkey/syndicate(antag.current), SLOT_R_STORE)