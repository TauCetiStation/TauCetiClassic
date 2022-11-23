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

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudheadrevolutionary"

	var/rev_cooldown = 0
	skillset_type = /datum/skillset/max

/datum/role/rev_leader/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, 1, "rev")

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

/datum/role/rev_leader/flash_rev_leader/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current
	H.equip_to_slot_or_del(new /obj/item/device/flash/rev_flash, SLOT_IN_BACKPACK)

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

/obj/item/device/flash/rev_flash
	var/headrev_only = TRUE

/obj/item/device/flash/rev_flash/AdjustFlashEffect(mob/living/M)
	M.AdjustWeakened(rand(6, 10))
	M.flash_eyes()

/obj/item/device/flash/rev_flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The [name] is broken</span>")
		return
	flash_recharge()
	var/datum/role/user_role = null
	//if we don't need conversion by other revolutionaries/antags
	if(headrev_only)
		if(isrole(HEADREV, user))
			user_role = user.mind.GetRole(HEADREV)
	//find user's roles, early return if have nothing
	else
		for(var/role in user.mind.antag_roles)
			var/datum/role/R = user.mind.GetRole(role)
			if(R)
				user_role = R
				break
	if(!user_role)
		to_chat(user, "<span class='warning'>*click* *click*</span>")
		return
	//select target [choice] for convert
	var/list/victim_list = list()
	for(var/mob/living/carbon/human/H in view(1, user))
		if(H == user)
			continue
		var/image/I = image(H.icon, H.icon_state)
		I.appearance = H
		victim_list[H] = I
	var/mob/living/carbon/human/choice = show_radial_menu(user, src, victim_list, tooltips = TRUE)
	if(!choice)
		return
	//check target implants, mind
	if(choice.ismindshielded())
		to_chat(user, "<span class='warning'>[choice] mind seems to be protected!</span>")
		return
	if(choice.isloyal())
		to_chat(user, "<span class='warning'>[choice] mind is already washed by Nanotrasen!</span>")
		return
	if(!choice.client || !choice.mind)
		to_chat(user, "<span class='warning'>The target must be conscious and have mind!</span>")
		return
	//if you break the distance, there should be no effect
	if(get_dist(user, choice) > 1)
		to_chat(user, "<span class='warning'>You need to be closer to [choice]!</span>")
		return
	/*	Concept requires: target must be incapacitating.
		There is no meta on revolution and that device.
		We dont need lol-convert					*/
	var/have_incapacitating = FALSE
	for(var/effect in choice.status_effects)
		var/datum/status_effect/incapacitating/S = effect
		if(S)
			have_incapacitating = TRUE
	if(!have_incapacitating)
		to_chat(user, "<span class='warning'>Make [choice] helpless against you!</span>")
		return
	//find all user's factions and add target as recruit.
	var/list/factions = find_factions_by_member(user_role, user.mind)
	for(var/datum/faction/faction in factions)
		add_faction_member(faction, choice)
	//red color flash for attract attention
	flash_lighting_fx(_color = LIGHT_COLOR_FIREPLACE)
	playsound(src, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)
	flick("flash2", src)
	//give them time to think about the situation
	choice.AdjustSleeping(2)

/obj/item/device/flash/rev_flash/emp_act(severity)
	return
