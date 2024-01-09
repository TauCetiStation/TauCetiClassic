/datum/role/traitor
	name = TRAITOR
	id = TRAITOR
	required_pref = ROLE_TRAITOR
	logo_state = "synd-logo"

	restricted_jobs = list("Cyborg", "Security Cadet", "Internal Affairs Agent", "Security Officer", "Warden", "Head of Security", "Captain", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor", "Blueshield Officer")
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"

	greets = list(GREET_SYNDBEACON, GREET_LATEJOIN, GREET_AUTOTRAITOR, GREET_ROUNDSTART, GREET_DEFAULT)

	var/give_uplink = TRUE
	var/telecrystals = 20
	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc
	change_to_maximum_skills = FALSE

/datum/role/traitor/New()
	..()
	if(give_uplink)
		AddComponent(/datum/component/gamemode/syndicate, telecrystals, "traitor")

/datum/role/traitor/proc/add_one_objective(datum/mind/traitor)
	switch(rand(1,120))
		if(1 to 20)
			AppendObjective(/datum/objective/target/assassinate, TRUE)
		if(21 to 40)
			AppendObjective(/datum/objective/target/harm, TRUE)
		if(41 to 50)
			AppendObjective(/datum/objective/research_sabotage, TRUE)
		if(51 to 115)
			AppendObjective(/datum/objective/steal, TRUE)
		else
			AppendObjective(/datum/objective/target/dehead, TRUE)

/datum/role/traitor/forgeObjectives()
	if(!..())
		return FALSE
	create_traitor_objectives()
	return TRUE

/datum/role/traitor/proc/create_traitor_objectives()
	if(issilicon(antag.current))
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

/datum/role/traitor/process()
	// For objectives such as "Make an example of...", which require mid-game checks for completion
	if(locate(/datum/objective/target/harm) in objectives.GetObjectives())
		for(var/datum/objective/target/harm/H in objectives.GetObjectives())
			H.check_completion()

/datum/role/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Выполните свои цели любой ценой. Вы можете игнорировать все остальные законы."
	var/law_borg = "Выполните цели своего ИИ любой ценой. Вы можете игнорировать все остальные законы."
	to_chat(killer, "<b>Ваши законы были изменены!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "Новый закон: 0. [law]")

	killer.add_language(LANGUAGE_SYCODE)

	if(isAI(killer))
		qdel(killer.aiRadio.keyslot1)
		killer.aiRadio.keyslot1 = new /obj/item/device/encryptionkey/syndicate()
		killer.aiRadio.recalculateChannels()

/datum/role/traitor/Greet(greeting = GREET_DEFAULT, custom)
	antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	if(!greeting)
		return

	var/icon/logo = get_logo_icon()
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "[bicon(logo, css = "style='position:relative; top:10;'")] <span class='danger'>You are a Syndicate agent, a Traitor.</span>")
		if (GREET_AUTOTRAITOR)
			to_chat(antag.current, "[bicon(logo, css = "style='position:relative; top:10;'")] <span class='danger'>You are now a Traitor.<br>Your memory clears up as you remember your identity as a sleeping agent of the Syndicate. It's time to pay your debt to them. </span>")
		if (GREET_LATEJOIN)
			to_chat(antag.current, "[bicon(logo, css = "style='position:relative; top:10;'")] <span class='danger'>You are a Traitor.<br>As a Syndicate agent, your goal is to infiltrate the crew and accomplish your objectives at all costs.</span>")
		if (GREET_SYNDBEACON)
			to_chat(antag.current, "[bicon(logo, css = "style='position:relative; top:10;'")] <span class='danger'>You have joined the ranks of the Syndicate and thus became a traitor to the Nanotrasen!</span>")
		else
			to_chat(antag.current, "[bicon(logo, css = "style='position:relative; top:10;'")] <span class='danger'>You are a Traitor.</span>")

	return TRUE

/datum/role/traitor/OnPostSetup(laterole)
	. = ..()
	if(issilicon(antag.current))
		add_law_zero(antag.current)
		return
	for(var/datum/objective/O in objectives.GetObjectives())
		O.give_required_equipment()

/datum/role/traitor/RemoveFromRole(datum/mind/M, msg_admins)
	if(isAI(M.current))
		var/mob/living/silicon/ai/AI = M.current
		qdel(AI.aiRadio.keyslot1)
		AI.aiRadio.keyslot1 = new /obj/item/device/encryptionkey()
		AI.aiRadio.recalculateChannels()
	. = ..()

/datum/role/traitor/wishgranter

/datum/role/traitor/wishgranter/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/custom/wishgranter)
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
	to_chat(antag.current, "<span class='userdanger'> <B>ATTENTION:</B> You hear a call from the Syndicate...</span>")

/datum/role/traitor/syndcall/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current
	H.equip_or_collect(new /obj/item/device/encryptionkey/syndicate(antag.current), SLOT_R_STORE)

/datum/role/traitor/imposter
	name = IMPOSTER
	id = IMPOSTER
	required_pref = ROLE_IMPOSTER
	//No restricts, everyone can be a imposter
	restricted_jobs = list()
	//Challenge
	give_uplink = FALSE
	telecrystals = 0

/datum/role/traitor/imposter/add_one_objective(datum/mind/traitor)
	switch(rand(1, 100))
		//most imposters is just stealers
		if(1 to 70)
			var/datum/job/J = SSjob.GetJob(antag.assigned_role)
			//remove objectives for heads of staff to steal own items
			if(J && (J.flags & JOB_FLAG_HEAD_OF_STAFF))
				AppendObjective(/datum/objective/steal/non_heads_items, TRUE)
			else
				AppendObjective(/datum/objective/steal, TRUE)
		if(71 to 80)
			AppendObjective(/datum/objective/target/assassinate, TRUE)
		if(81 to 90)
			AppendObjective(/datum/objective/target/harm, TRUE)
		else
			AppendObjective(/datum/objective/target/dehead, TRUE)

/datum/role/traitor/imposter/proc/add_killhead_objectives()
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		if(antag == head_mind)
			continue
		var/datum/objective/target/assassinate/killhead_obj = AppendObjective(/datum/objective/target/assassinate, TRUE)
		if(killhead_obj)
			killhead_obj.target = head_mind

/datum/role/traitor/imposter/create_traitor_objectives()
	if(issilicon(antag.current))
		//probability 10% for default silent assassin AI
		if(prob(10))
			log_mode("IMPOSTERS: silicon imposter ([antag.current]) has standart objectives")
			return ..()
		//probability 90% for peace-protecter AI
		AppendObjective(/datum/objective/target/protect, TRUE)
		AppendObjective(/datum/objective/target/protect, TRUE)
		AppendObjective(/datum/objective/survive)
		log_mode("IMPOSTERS: silicon imposter ([antag.current]) has protect objectives")
		//and 10% prob to hijack shuttle when has protect objective
		if(prob(10))
			AppendObjective(/datum/objective/block)
			log_mode("IMPOSTERS: silicon [antag.current] has hijack with protect objectives")
		return
	//5% prob to killhead objectives for non-silicon imposter
	if(prob(5))
		add_killhead_objectives()
		log_mode("IMPOSTERS: Non-silicon imposter ([antag.current]) has killhead objectives")
		return
	//default traitor objectives
	for(var/i in 1 to 3)
		add_one_objective()
	//Setup last objective
	switch(rand(1, 100))
		//Escape is more interesting
		if(1 to 90)
			AppendObjective(/datum/objective/escape)
		if(91 to 99)
			AppendObjective(/datum/objective/survive)
		else
			AppendObjective(/datum/objective/hijack)
	log_mode("IMPOSTERS: Non-silicon imposter ([antag.current]) has standart traitor objectives")

/datum/role/traitor/imposter/OnPostSetup(laterole)
	. = ..()
	if(antag.current.isloyal() && iscarbon(antag.current))
		var/mob/living/carbon/C = antag.current
		C.fake_loyal_implant_replacement()
	// Free a unit from AI
	if(isrobot(antag.current))
		var/mob/living/silicon/robot/robot = antag.current
		robot.UnlinkSelf()
		robot.emagged = TRUE

/mob/living/carbon/proc/fake_loyal_implant_replacement()
	for(var/obj/item/weapon/implant/mind_protect/loyalty/L in src)
		qdel(L)
	var/obj/item/weapon/implant/fake_loyal/F = new(src)
	F.inject(src, BP_CHEST)

// Now dont show green/red text
/datum/role/traitor/imposter/GetObjectiveDescription(datum/objective/objective)
	return "[objective.explanation_text]"
