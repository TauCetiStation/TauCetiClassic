/datum/role/rev
	name = REV
	id = REV
	required_pref = ROLE_REV
	logo_state = "rev-logo"

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudrevolutionary"

/datum/role/rev/CanBeAssigned(datum/mind/M)
	if(!..())
		return FALSE
	if(M.current.ismindprotect())
		return FALSE
	if(jobban_isbanned(M.current, ROLE_REV) || jobban_isbanned(M.current, "Syndicate"))
		return FALSE
	return TRUE

/datum/role/rev/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill, capture or convert the heads to win the revolution!</FONT></span>")

/datum/role/rev_leader
	name = HEADREV
	id = HEADREV
	required_pref = ROLE_REV
	logo_state = "rev_head-logo"

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudheadrevolutionary"

	var/rev_cooldown = 0

/datum/role/rev_leader/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, 20)

/datum/role/rev_leader/OnPostSetup(laterole)
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
	else if(M.ismindprotect())
		to_chat(src, "<span class='warning'><b>[M] is implanted with a mind protected implant - Remove it first!</b></span>")
	else if(jobban_isbanned(M, ROLE_REV) || jobban_isbanned(M, "Syndicate"))
		to_chat(src, "<span class='warning'><b>[M] is a blacklisted player!</b></span>")
	else
		var/datum/role/rev_leader/lead = mind.GetRole(HEADREV)
		if(world.time < lead.rev_cooldown)
			to_chat(src, "<span class='warning'>Wait five seconds before reconversion attempt.</span>")
			return
		to_chat(src, "<span class='warning'>Attempting to convert [M]...</span>")
		log_admin("[key_name(src)]) attempted to convert [M].")
		message_admins("<span class='warning'>[key_name_admin(src)] attempted to convert [M]. [ADMIN_JMP(src)]</span>")
		var/choice = tgui_alert(M,"Asked by [src]: Do you want to join the revolution?","Join the Revolution!",list("No!","Yes!"))
		if(choice == "Yes!")
			var/datum/faction/revolution/rev = lead.GetFaction()
			if(add_faction_member(rev, M, TRUE))
				to_chat(M, "<span class='notice'>You join the revolution!</span>")
				to_chat(src, "<span class='notice'><b>[M] joins the revolution!</b></span>")
			else
				to_chat(src, "<span class='warning'><b>[M] cannot be converted.</b></span>")
		else if(choice == "No!")
			to_chat(M, "<span class='warning'>You reject this traitorous cause!</span>")
			to_chat(src, "<span class='warning'><b>[M] does not support the revolution!</b></span>")
		lead.rev_cooldown = world.time + 50
