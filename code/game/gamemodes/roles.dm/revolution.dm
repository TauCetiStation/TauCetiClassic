/datum/role/rev
	name = REV
	id = REV
	required_pref = REV
	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
	logo_state = "rev-logo"

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudheadrevolutionary"

/datum/role/rev/CanBeAssigned(datum/mind/M)
	if(!..())
		return FALSE
	if(ismindshielded(M.current) || isloyal(M.current))
		return FALSE
	if(jobban_isbanned(M.current, REV) || jobban_isbanned(M.current, "Syndicate") || role_available_in_minutes(M.current, REV))
		return FALSE
	return TRUE

/datum/role/rev/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill, capture or convert the heads to win the revolution!</FONT></span>")

/datum/role/syndicate/rev_leader
	name = HEADREV
	id = HEADREV
	required_pref = REV
	logo_state = "rev_head-logo"

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudrevolutionary"

	var/rev_cooldown = 0

/datum/role/syndicate/rev_leader/OnPostSetup(laterole)
	. = ..()
	antag.current.verbs += /mob/living/carbon/human/proc/RevConvert

	// Show each head revolutionary up to 3 candidates
	var/list/already_considered = list()
	for(var/i in 1 to 2)
		var/mob/rev_mob = antag.current
		already_considered += rev_mob
		// Tell them about people they might want to contact.
		var/mob/living/carbon/human/M = get_nt_opposed()
		if(M && !isrevhead(M) && !(M in already_considered))
			to_chat(rev_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
			rev_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

	equip_traitor(antag.current)

/mob/living/carbon/human/proc/RevConvert()
	set name = "Rev-Convert"
	set category = "IC"

	if(!isrevhead(src))
		verbs -= /mob/living/carbon/human/proc/RevConvert
		return FALSE

	var/list/Possible = list()
	for(var/mob/living/carbon/human/P in oview(src))
		if(!stat && P.client && P.mind && (!isrev(P) || !isrevhead(P)))
			Possible += P
	if(!Possible.len)
		to_chat(src, "<span class='warning'>There doesn't appear to be anyone available for you to convert here.</span>")
		return

	var/mob/living/carbon/human/M = input("Select a person to convert", "Viva la revolution!", null) as mob in Possible
	if(!isrevhead(src))
		verbs -= /mob/living/carbon/human/proc/RevConvert
		return FALSE

	if(isrevhead(M) || isrev(M))
		to_chat(src, "<span class='warning'><b>[M] is already be a revolutionary!</b></span>")
	else if(ismindshielded(M))
		to_chat(src, "<span class='warning'><b>[M] is implanted with a loyalty implant - Remove it first!</b></span>")
	else if(jobban_isbanned(M, REV) || jobban_isbanned(M, "Syndicate") || role_available_in_minutes(M, REV))
		to_chat(src, "<span class='warning'><b>[M] is a blacklisted player!</b></span>")
	else
		var/datum/role/syndicate/rev_leader/lead = mind.GetRole(HEADREV)
		if(world.time < lead.rev_cooldown)
			to_chat(src, "<span class='warning'>Wait five seconds before reconversion attempt.</span>")
			return
		to_chat(src, "<span class='warning'>Attempting to convert [M]...</span>")
		log_admin("[key_name(src)]) attempted to convert [M].")
		message_admins("<span class='warning'>[key_name_admin(src)] attempted to convert [M]. [ADMIN_JMP(src)]</span>")
		var/choice = alert(M,"Asked by [src]: Do you want to join the revolution?","Align Thyself with the Revolution!","No!","Yes!")
		if(choice == "Yes!")
			var/datum/faction/revolution/rev = lead.GetFaction()
			rev.HandleRecruitedMind(M.mind)
			to_chat(M, "<span class='notice'>You join the revolution!</span>")
			to_chat(src, "<span class='notice'><b>[M] joins the revolution!</b></span>")
		else if(choice == "No!")
			to_chat(M, "<span class='warning'>You reject this traitorous cause!</span>")
			to_chat(src, "<span class='warning'><b>[M] does not support the revolution!</b></span>")
		lead.rev_cooldown = world.time + 50
