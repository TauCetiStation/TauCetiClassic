/datum/role/heretic
	name = HERETIC
	id = HERETIC
	required_pref = ROLE_HERETIC
	logo_state = "heretic-logo"

	restricted_jobs = list("Security Cadet", "Chaplain", "AI", "Cyborg", "Security Officer", "Warden", "Head of Security", "Captain", "Internal Affairs Agent", "Blueshield Officer")
	antag_hud_type = ANTAG_HUD_HERETIC
	antag_hud_name = "heretic"

	greets = list(GREET_CUSTOM)

	var/give_grasp = TRUE
	skillset_type = /datum/skillset/cultist
	moveset_type = /datum/combat_moveset/cqc
	change_to_maximum_skills = FALSE

/datum/role/heretic/Greet(greeting, custom)
	if(!..())
		return FALSE
	antag.current.playsound_local(null, 'sound/antag/heretic_gain.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='heretic'>Вы - еретик, грязный книжный червь. </span>")
	to_chat(antag.current, "<span class='heretic'>Совсем недавно вам приснился темный лес и старик.</span>")
	to_chat(antag.current, "<span class='heretic'>Вы собираетесь пройти через трехстворчатые ворота и попасть на вершину Мансуса, где свет ярче обычного.</span>")
	to_chat(antag.current, "<span class='heretic'>Сила забытых богов в ваших руках.</span>")
	to_chat(antag.current, "<span class='heretic'>Никто или ничто не может остановить вас и ваши сны.</span>")

/datum/role/heretic/New()
	..()

/datum/role/heretic/OnPostSetup(laterole)
	. = ..()

	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "heretic", /datum/mood_event/heretic)
	if(give_grasp)
		antag.current.AddSpell(new /obj/effect/proc_holder/spell/in_hand/mansus_grasp)
	for(var/datum/objective/O in objectives.GetObjectives())
		O.give_required_equipment()

/datum/role/heretic/proc/add_one_objective(datum/mind/heretic)
	switch(rand(1,120))
		if(1 to 20)
			AppendObjective(/datum/objective/target/assassinate, TRUE)
		if(21 to 25)
			AppendObjective(/datum/objective/target/harm, TRUE)
		if(26 to 30)
			AppendObjective(/datum/objective/bomb, FALSE)
		if(31 to 40)
			AppendObjective(/datum/objective/download_telecommunications_data, FALSE)
		if(41 to 50)
			AppendObjective(/datum/objective/research_sabotage, FALSE)
		if(51 to 115)
			AppendObjective(/datum/objective/steal, TRUE)
		else
			AppendObjective(/datum/objective/target/dehead, TRUE)

/datum/role/heretic/forgeObjectives()
	if(!..())
		return FALSE
	create_traitor_objectives()
	return TRUE

/datum/role/heretic/proc/create_traitor_objectives()
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

/datum/role/heretic/process()
	// For objectives such as "Make an example of...", which require mid-game checks for completion
	if(locate(/datum/objective/target/harm) in objectives.GetObjectives())
		for(var/datum/objective/target/harm/H in objectives.GetObjectives())
			H.check_completion()


