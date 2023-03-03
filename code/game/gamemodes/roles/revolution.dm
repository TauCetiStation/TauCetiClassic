/datum/role/rev
	name = REV
	id = REV
	required_pref = ROLE_REV
	logo_state = "rev-logo"

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudrevolutionary"
	skillset_type = /datum/skillset/revolutionary

/datum/role/rev/CanBeAssigned(datum/mind/M)
	if(!..())
		return FALSE
	if(M.current.ismindprotect())
		return FALSE
	//Enemy of revolution can be converted to Revolution
	var/datum/role/R = M.GetRole(ENEMY_REV)
	if(R)
		R.Deconvert()
	return TRUE

/datum/role/rev/OnPreSetup(greeting, custom)
	. = ..()
	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "rev_convert", /datum/mood_event/rev)

/datum/role/rev/RemoveFromRole(datum/mind/M, msg_admins)
	SEND_SIGNAL(antag.current, COMSIG_CLEAR_MOOD_EVENT, "rev_convert")
	..()

/datum/role/rev/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill, capture or convert the heads to win the revolution!</FONT></span>")

/datum/role/rev_leader
	name = HEADREV
	id = HEADREV
	required_pref = ROLE_REV
	logo_state = "rev_head-logo"

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent", "Blueshield Officer")

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudheadrevolutionary"

	var/rev_cooldown = 0
	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc

/datum/role/rev_leader/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current
	H.equip_or_collect(new /obj/item/device/flash/rev_flash, SLOT_IN_BACKPACK)

/mob/living/carbon/human/proc/RevConvert()
	set name = "Rev-Convert"
	set category = "IC"

	if(!isrevhead(src))
		verbs -= /mob/living/carbon/human/proc/RevConvert
		return FALSE

	var/list/Possible = list()
	for(var/mob/living/carbon/human/P in oview(src))
		if(stat == CONSCIOUS && P.client && P.mind && (!isrev(P) || !isrevhead(P)))
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
				var/obj/item/device/uplink/hidden/U = find_syndicate_uplink(src)
				if(!U)
					return
				U.uses += 3
				var/datum/component/gamemode/syndicate/S = lead.GetComponent(/datum/component/gamemode/syndicate)
				if(!S)
					return
				S.total_TC += 3

			else
				to_chat(src, "<span class='warning'><b>[M] cannot be converted.</b></span>")
		else if(choice == "No!")
			to_chat(M, "<span class='warning'>You reject this traitorous cause!</span>")
			to_chat(src, "<span class='warning'><b>[M] does not support the revolution!</b></span>")
		lead.rev_cooldown = world.time + 50
