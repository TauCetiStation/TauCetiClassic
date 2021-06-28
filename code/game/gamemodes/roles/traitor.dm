/datum/role/traitor
	name = TRAITOR
	id = TRAITOR
	required_pref = ROLE_TRAITOR
	logo_state = "synd-logo"

	restricted_jobs = list("Cyborg", "Security Cadet", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"

	greets = list(GREET_SYNDBEACON, GREET_LATEJOIN, GREET_AUTOTATOR, GREET_ROUNDSTART)

/datum/role/traitor/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, 20)

/datum/role/traitor/proc/add_one_objective(datum/mind/traitor)
	switch(rand(1,120))
		if(1 to 20)
			AppendObjective(/datum/objective/target/assassinate, TRUE)
		if(21 to 50)
			AppendObjective(/datum/objective/target/harm, TRUE)
		if(51 to 115)
			AppendObjective(/datum/objective/steal, TRUE)
		else
			AppendObjective(/datum/objective/target/dehead, TRUE)

/datum/role/traitor/forgeObjectives()
	if(!..())
		return FALSE
	if(istype(antag.current, /mob/living/silicon))
		AppendObjective(/datum/objective/target/assassinate, TRUE)
		AppendObjective(/datum/objective/target/assassinate, TRUE)
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
	return TRUE

/datum/role/traitor/process()
	// For objectives such as "Make an example of...", which require mid-game checks for completion
	if(locate(/datum/objective/target/harm) in objectives.GetObjectives())
		for(var/datum/objective/target/harm/H in objectives.GetObjectives())
			H.check_completion()

/datum/role/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs. You may ignore all other laws."
	var/law_borg = "Accomplish your AI's objectives at all costs. You may ignore all other laws."
	to_chat(killer, "<b>Your laws have been changed!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "New law: 0. [law]")

	killer.add_language("Sy-Code", 1)

/datum/role/traitor/Greet(greeting, custom)
	if (istype(antag.current, /mob/living/silicon))
		add_law_zero(antag.current)
		antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else
		antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	if(!greeting)
		return

	var/icon/logo = get_logo_icon()
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

/datum/role/traitor/wishgtanter

/datum/role/traitor/wishgtanter/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/custom/wishgtanter)
	AppendObjective(/datum/objective/escape)
	return TRUE

/datum/role/traitor/syndbeacon

/datum/role/traitor/syndbeacon/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/silence)
	return TRUE

/datum/role/traitor/syndcall

/datum/role/traitor/syndcall/Greet(greeting, custom)
	..()
	to_chat(antag.current, "<span class='userdanger'> <B>ATTENTION:</B> You hear a call from Syndicate...</span>")

/datum/role/traitor/syndcall/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current
	H.equip_or_collect(new /obj/item/device/encryptionkey/syndicate(antag.current), SLOT_R_STORE)