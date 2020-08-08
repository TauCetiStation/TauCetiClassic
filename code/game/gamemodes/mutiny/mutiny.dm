//no declare_completion?

#define MUTINY_RECRUITMENT_COOLDOWN 5

/datum/game_mode/mutiny
	var/datum/mutiny_fluff/fluff
	var/datum/directive/current_directive
	var/obj/item/weapon/mutiny/auth_key/captain/captains_key
	var/obj/item/weapon/mutiny/auth_key/secondary/secondary_key
	var/obj/machinery/emergency_authentication_device/ead
	var/datum/mind/head_loyalist
	var/datum/mind/head_mutineer
	var/recruit_loyalist_cooldown = 0
	var/recruit_mutineer_cooldown = 0
	var/list/loyalists = list()
	var/list/mutineers = list()
	var/list/body_count = list()

	name = "mutiny"
	config_tag = "mutiny"
	role_type = ROLE_MUTINEER
	required_players = 7
	recommended_enemies = 2
	required_players_secret = 10

	votable = 0

	ert_disabled = 1

	uplink_welcome = "Mutineers Uplink Console:"
	uplink_uses = 0

/datum/game_mode/mutiny/New()
	fluff = new(src)

/datum/game_mode/mutiny/Destroy()
	qdel(fluff)
	return ..()

/datum/game_mode/mutiny/proc/reveal_directives()
	spawn(rand(1 MINUTE, 3 MINUTES))
		command_alert("Incoming emergency directive: Captain's office fax machine, [station_name()].","Emergency Transmission")
		spawn(rand(3 MINUTES, 5 MINUTES))
			send_pda_message()
		spawn(rand(3 MINUTES, 5 MINUTES))
			fluff.announce_directives()
			spawn(rand(2 MINUTES, 3 MINUTE))

				var/list/reasons = list(
					"political instability",
					"quantum fluctuations",
					"hostile raiders",
					"derelict station debris",
					"REDACTED",
					"ancient alien artillery",
					"solar magnetic storms",
					"sentient time-travelling killbots",
					"gravitational anomalies",
					"wormholes to another dimension",
					"a telescience mishap",
					"radiation flares",
					"supermatter dust",
					"leaks into a negative reality",
					"antiparticle clouds",
					"residual bluespace energy",
					"suspected syndicate operatives",
					"malfunctioning von Neumann probe swarms",
					"shadowy interlopers",
					"a stranded Vox arkship",
					"haywire IPC constructs",
					"rogue Unathi exiles",
					"artifacts of eldritch horror",
					"a brain slug infestation",
					"killer bugs that lay eggs in the husks of the living",
					"a deserted transport carrying xenomorph specimens",
					"an emissary for the gestalt requesting a security detail",
					"a Tajaran slave rebellion",
					"radical Skrellian transevolutionaries",
					"classified security operations",
					"science-defying raw elemental chaos"
					)
				command_alert("The presence of [pick(reasons)] in the region is tying up all available local emergency resources; emergency response teams cannot be called at this time.","Emergency Transmission")

// Returns an array in case we want to expand on this later.
/datum/game_mode/mutiny/proc/get_head_loyalist_candidates()
	var/list/candidates[0]
	for(var/mob/loyalist in player_list)
		if(loyalist.mind && loyalist.mind.assigned_role == "Captain")
			candidates.Add(loyalist.mind)
	return candidates

/datum/game_mode/mutiny/proc/get_head_mutineer_candidates()
	var/list/candidates[0]
	for(var/mob/mutineer in player_list)
		if(ROLE_MUTINEER in mutineer.client.prefs.be_role)
			for(var/job in command_positions - "Captain")
				if(mutineer.mind && mutineer.mind.assigned_role == job)
					candidates.Add(mutineer.mind)
	return candidates

/datum/game_mode/mutiny/proc/get_directive_candidates()
	var/list/candidates[0]
	for(var/T in typesof(/datum/directive) - /datum/directive)
		var/datum/directive/D = new T(src)
		if (D.meets_prerequisites())
			candidates.Add(D)
	return candidates

/datum/game_mode/mutiny/proc/send_pda_message()
	var/obj/item/device/pda/pda = null
	for(var/obj/item/device/pda/P in head_mutineer.current)
		pda = P
		break

	if (!pda)
		return 0

	if (!pda.message_silent)
		playsound(pda, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
		pda.audible_message("[bicon(pda)] *[pda.ttone]*", hearing_distance = 3)

	to_chat(head_mutineer.current, fluff.get_pda_body())
	return 1

/datum/game_mode/mutiny/proc/get_equipment_slots()
	return list(
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE,
		"backpack" = SLOT_IN_BACKPACK,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND)

/datum/game_mode/mutiny/proc/equip_head_loyalist()
	equip_head(head_loyalist, "loyalist", /mob/living/carbon/human/proc/recruit_loyalist)

/datum/game_mode/mutiny/proc/equip_head_mutineer()
	equip_head(head_mutineer, "mutineer", /mob/living/carbon/human/proc/recruit_mutineer)

/datum/game_mode/mutiny/proc/equip_head(datum/mind/head, faction, recruitment_verb)
	var/mob/living/carbon/human/H = head.current
	to_chat(H, "You are the Head [capitalize(faction)]!")
	head.special_role = "head_[faction]"

	var/slots = get_equipment_slots()
	switch(faction)
		if("loyalist")
			if(captains_key) del(captains_key)
			captains_key = new(H)
			H.equip_in_one_of_slots(captains_key, slots)
		if("mutineer")
			if(secondary_key) del(secondary_key)
			secondary_key = new(H)
			H.equip_in_one_of_slots(secondary_key, slots)

	H.update_icons()
	H.verbs += recruitment_verb

/datum/game_mode/mutiny/proc/add_loyalist(datum/mind/M)
	add_faction(M, "loyalist", loyalists)

/datum/game_mode/mutiny/proc/add_mutineer(datum/mind/M)
	add_faction(M, "mutineer", mutineers)

/datum/game_mode/mutiny/proc/add_faction(datum/mind/M, faction, list/faction_list)
	if(!can_be_recruited(M, faction))
		to_chat(M.current, "<span class='warning'>Recruitment canceled; your role has already changed.</span>")
		to_chat(head_mutineer.current, "<span class='warning'>Could not recruit [M]. Their role has changed.</span>")
		return

	if(M in loyalists)
		loyalists.Remove(M)

	if(M in mutineers)
		mutineers.Remove(M)

	M.special_role = faction
	faction_list.Add(M)

	if(faction == "mutineer")
		to_chat(M.current, fluff.mutineer_tag("You have joined the mutineers!"))
		to_chat(head_mutineer.current, fluff.mutineer_tag("[M] has joined the mutineers!"))
	else
		to_chat(M.current, fluff.loyalist_tag("You have joined the loyalists!"))
		to_chat(head_loyalist.current, fluff.loyalist_tag("[M] has joined the loyalists!"))

	update_icon(M)

/datum/game_mode/mutiny/proc/was_bloodbath()
	var/list/remaining_loyalists = loyalists - body_count
	if (!remaining_loyalists.len)
		return 1

	var/list/remaining_mutineers = mutineers - body_count
	if (!remaining_mutineers.len)
		return 1

	return 0

/datum/game_mode/mutiny/proc/replace_nuke_with_ead()
	for(var/obj/machinery/nuclearbomb/N in poi_list)
		ead = new(N.loc, src)
		qdel(N)

/datum/game_mode/mutiny/proc/unbolt_vault_door()
	var/obj/machinery/door/airlock/vault/V = locate() in airlock_list
	V.locked = 0

/datum/game_mode/mutiny/proc/make_secret_transcript()
	var/obj/machinery/computer/telecomms/server/S = locate() in computer_list
	if(!S) return

	var/obj/item/weapon/paper/crumpled/bloody/transcript = new(S.loc)
	transcript.name = "secret transcript"
	transcript.info = fluff.secret_transcript()

/datum/game_mode/mutiny/proc/can_be_recruited(datum/mind/M, role)
	if(!M) return 0
	if(!M.special_role) return 1
	switch(role)
		if("loyalist")
			return M.special_role == "mutineer"
		if("mutineer")
			return M.special_role == "loyalist"

/datum/game_mode/mutiny/proc/reassign_employee(obj/item/weapon/card/id/id_card)
	var/datum/directive/research_to_ripleys/D1 = get_directive("research_to_ripleys")
	if(D1)
		if(D1.ids_to_reassign && D1.ids_to_reassign.Find(id_card))
			D1.ids_to_reassign[id_card] = id_card.assignment == "Shaft Miner" ? 1 : 0

	var/datum/directive/tau_ceti_needs_women/D2 = get_directive("tau_ceti_needs_women")
	if(D2)
		if(D2.command_targets && D2.command_targets.Find(id_card))
			D2.command_targets[id_card] = command_positions.Find(id_card.assignment) ? 0 : 1

/datum/game_mode/mutiny/proc/terminate_employee(obj/item/weapon/card/id)
	var/datum/directive/ipc_virus/D1 = get_directive("ipc_virus")
	if(D1)
		if(D1.ids_to_terminate && D1.ids_to_terminate.Find(id))
			D1.ids_to_terminate.Remove(id)

	var/datum/directive/tau_ceti_needs_women/D2 = get_directive("tau_ceti_needs_women")
	if(D2)
		if(D2.alien_targets && D2.alien_targets.Find(id))
			D2.alien_targets.Remove(id)
		if(D2.command_targets && D2.command_targets.Find(id))
			D2.command_targets[id] = 1

	var/datum/directive/terminations/D3 = get_directive("terminations")
	if(D3)
		if(D3.ids_to_terminate && D3.ids_to_terminate.Find(id))
			D3.ids_to_terminate.Remove(id)

/datum/game_mode/mutiny/proc/borgify_directive(mob/living/silicon/robot/cyborg)
	var/datum/directive/ipc_virus/D = get_directive("ipc_virus")
	if (!D) return

	if(D.cyborgs_to_make.Find(cyborg.mind))
		D.cyborgs_to_make.Remove(cyborg.mind)

	// In case something glitchy happened and the victim got
	// borged without us tracking the brain removal, go ahead
	// and update that list too.
	if(D.brains_to_enslave.Find(cyborg.mind))
		D.brains_to_enslave.Remove(cyborg.mind)

/datum/game_mode/mutiny/proc/deliver_materials(obj/structure/closet/crate/sold, area/shuttle)
	var/datum/directive/research_to_ripleys/D = get_directive("research_to_ripleys")
	if(!D) return

	for(var/atom/A in sold)
		if(istype(A, /obj/item/stack/sheet/mineral) || istype(A, /obj/item/stack/sheet/metal))
			var/obj/item/stack/S = A
			D.materials_shipped += S.get_amount()

/datum/game_mode/mutiny/proc/suspension_directive(datum/money_account/account)
	var/datum/directive/terminations/D = get_directive("terminations")
	if (!D) return

	if(D.accounts_to_suspend && D.accounts_to_suspend.Find("[account.account_number]"))
		D.accounts_to_suspend["[account.account_number]"] = account.suspended

/datum/game_mode/mutiny/proc/payroll_directive(datum/money_account/account)
	var/datum/directive/terminations/D = get_directive("terminations")
	if (!D) return

	if(D.accounts_to_revoke && D.accounts_to_revoke.Find("[account.account_number]"))
		D.accounts_to_revoke["[account.account_number]"] = 1

/datum/game_mode/mutiny/proc/debrain_directive(obj/item/brain/B)
	var/datum/directive/ipc_virus/D = get_directive("ipc_virus")
	if (!D) return

	if(D.brains_to_enslave.Find(B.brainmob.mind))
		D.brains_to_enslave.Remove(B.brainmob.mind)

/datum/game_mode/mutiny/proc/infected_killed(mob/living/carbon/human/deceased)
	var/datum/directive/bluespace_contagion/D = get_directive("bluespace_contagion")
	if(!D) return

	if(deceased in D.infected)
		D.infected.Remove(deceased)

/datum/game_mode/mutiny/proc/round_outcome()
	to_chat(world, "<center><h4>Breaking News</h4></center><br><hr>")
	if (was_bloodbath())
		to_chat(world, fluff.no_victory())
		return

	var/directives_completed = current_directive.directives_complete()
	var/ead_activated = ead.activated
	if (directives_completed && ead_activated)
		to_chat(world, fluff.loyalist_major_victory())
	else if (directives_completed && !ead_activated)
		to_chat(world, fluff.loyalist_minor_victory())
	else if (!directives_completed && ead_activated)
		to_chat(world, fluff.mutineer_minor_victory())
	else if (!directives_completed && !ead_activated)
		to_chat(world, fluff.mutineer_major_victory())

	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)

/datum/game_mode/mutiny/proc/update_all_icons()
	spawn(0)
		for(var/datum/mind/M in mutineers)
			update_icon(M)

		for(var/datum/mind/M in loyalists)
			update_icon(M)
	return 1

/datum/game_mode/mutiny/proc/update_icon(datum/mind/M)
	if(!M.current || !M.current.client)
		return 0

	for(var/image/I in head_loyalist.current.client.images)
		if(I.loc == M.current && (I.icon_state == "loyalist" || I.icon_state == "mutineer"))
			qdel(I)

	for(var/image/I in head_mutineer.current.client.images)
		if(I.loc == M.current && (I.icon_state == "loyalist" || I.icon_state == "mutineer"))
			qdel(I)

	if(M in loyalists)
		var/I = image('icons/mob/mob.dmi', loc=M.current, icon_state = "loyalist")
		head_loyalist.current.client.images += I

	if(M in mutineers)
		var/I = image('icons/mob/mob.dmi', loc=M.current, icon_state = "mutineer")
		head_mutineer.current.client.images += I

	return 1

/datum/game_mode/mutiny/announce()
	fluff.announce()

/datum/game_mode/mutiny/pre_setup()
	var/list/loyalist_candidates = get_head_loyalist_candidates()
	if(!loyalist_candidates || loyalist_candidates.len == 0)
		to_chat(world, "<span class='warning'>Mutiny mode aborted: no valid candidates for head loyalist.</span>")
		return 0

	var/list/mutineer_candidates = get_head_mutineer_candidates()
	if(!mutineer_candidates || mutineer_candidates.len == 0)
		to_chat(world, "<span class='warning'>Mutiny mode aborted: no valid candidates for head mutineer.</span>")
		return 0

	var/list/directive_candidates = get_directive_candidates()
	if(!directive_candidates || directive_candidates.len == 0)
		to_chat(world, "<span class='warning'>Mutiny mode aborted: no valid candidates for Directive X.</span>")
		return 0

	head_loyalist = pick(loyalist_candidates)
	head_mutineer = pick(mutineer_candidates)
	current_directive = pick(directive_candidates)

	return 1

/datum/game_mode/mutiny/post_setup()
	equip_head_loyalist()
	equip_head_mutineer()

	loyalists.Add(head_loyalist)
	mutineers.Add(head_mutineer)

	replace_nuke_with_ead()
	current_directive.initialize()
	unbolt_vault_door()
	make_secret_transcript()

	update_all_icons()
	spawn(0)
		reveal_directives()
	return ..()

/mob/living/carbon/human/proc/recruit_loyalist()
	set name = "Recruit Loyalist"
	set category = "Mutiny"

	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode || src != mode.head_loyalist.current)
		return

	var/list/candidates = list()
	for (var/mob/living/carbon/human/P in oview(src))
		if(!stat && P.client && mode.can_be_recruited(P.mind, "loyalist"))
			candidates += P

	if(!candidates.len)
		to_chat(src, "<span class='warning'>You aren't close enough to anybody that can be recruited.</span>")
		return

	if(world.time < mode.recruit_loyalist_cooldown)
		to_chat(src, "<span class='warning'>Wait [MUTINY_RECRUITMENT_COOLDOWN] seconds before recruiting again.</span>")
		return

	mode.recruit_loyalist_cooldown = world.time + (MUTINY_RECRUITMENT_COOLDOWN SECONDS)

	var/mob/living/carbon/human/M = input("Select a person to recruit", "Loyalist recruitment", null) as mob in candidates

	if (M)
		to_chat(src, "Attempting to recruit [M]...")
		log_admin("[key_name(src)] attempted to recruit [M] as a loyalist.")
		message_admins("<span class='warning'>[key_name_admin(src)] attempted to recruit [M] as a loyalist. [ADMIN_JMP(src)]</span>")

		var/choice = alert(M, "Asked by [src]: Will you help me complete Directive X?", "Loyalist recruitment", "No", "Yes")
		if(choice == "Yes")
			mode.add_loyalist(M.mind)
		else if(choice == "No")
			to_chat(M, "<span class='warning'>You declined to join the loyalists.</span>")
			to_chat(mode.head_loyalist.current, "<span class='warning'><b>[M] declined to support the loyalists.</b></span>")

/mob/living/carbon/human/proc/recruit_mutineer()
	set name = "Recruit Mutineer"
	set category = "Mutiny"

	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode || src != mode.head_mutineer.current)
		return

	var/list/candidates = list()
	for (var/mob/living/carbon/human/P in oview(src))
		if(!stat && P.client && mode.can_be_recruited(P.mind, "mutineer"))
			candidates += P

	if(!candidates.len)
		to_chat(src, "<span class='warning'>You aren't close enough to anybody that can be recruited.</span>")
		return

	if(world.time < mode.recruit_mutineer_cooldown)
		to_chat(src, "<span class='warning'>Wait [MUTINY_RECRUITMENT_COOLDOWN] seconds before recruiting again.</span>")
		return

	mode.recruit_mutineer_cooldown = world.time + (MUTINY_RECRUITMENT_COOLDOWN SECONDS)

	var/mob/living/carbon/human/M = input("Select a person to recruit", "Mutineer recruitment", null) as mob in candidates

	if (M)
		to_chat(src, "Attempting to recruit [M]...")
		log_admin("[key_name(src)]) attempted to recruit [M] as a mutineer.")
		message_admins("<span class='warning'>[key_name_admin(src)] attempted to recruit [M] as a mutineer. [ADMIN_JMP(src)]</span>")

		var/choice = alert(M, "Asked by [src]: Will you help me stop Directive X?", "Mutineer recruitment", "No", "Yes")
		if(choice == "Yes")
			mode.add_mutineer(M.mind)
		else if(choice == "No")
			to_chat(M, "<span class='warning'>You declined to join the mutineers.</span>")
			to_chat(mode.head_mutineer.current, "<span class='warning'><b>[M] declined to support the mutineers.</b></span>")

/proc/get_mutiny_mode()
	if(!SSticker || !istype(SSticker.mode, /datum/game_mode/mutiny))
		return null

	return SSticker.mode
