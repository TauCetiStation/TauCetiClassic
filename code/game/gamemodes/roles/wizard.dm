/datum/role/wizard
	name = WIZARD
	id = WIZARD
	disallow_job = TRUE

	required_pref = ROLE_WIZARD

	restricted_jobs = list("Head of Security", "Captain")

	antag_hud_type = ANTAG_HUD_WIZ
	antag_hud_name = "hudwizard"

	logo_state = "wizard-logo"

/datum/role/wizard/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<B>The Space Wizards Federation has given you the following tasks:</B>")

/datum/role/wizard/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	M.current.ClearSpells()

/datum/role/wizard/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"

	var/newname = sanitize_safe(input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text, MAX_NAME_LEN)

	if(!newname)
		newname = randomname

	wizard_mob.real_name = newname
	wizard_mob.name = newname
	if(wizard_mob.mind)
		wizard_mob.mind.name = newname
	if(istype(wizard_mob.dna, /datum/dna))
		var/datum/dna/dna = wizard_mob.dna
		dna.real_name = newname

/datum/role/wizard/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	wizard_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), SLOT_L_EAR)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(wizard_mob), SLOT_W_UNIFORM)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), SLOT_SHOES)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), SLOT_WEAR_SUIT)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), SLOT_HEAD)
	if(wizard_mob.backbag == 2) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(wizard_mob), SLOT_BACK)
	if(wizard_mob.backbag == 3) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(wizard_mob), SLOT_BACK)
	if(wizard_mob.backbag == 4) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(wizard_mob), SLOT_BACK)
	if(wizard_mob.backbag == 5) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(wizard_mob), SLOT_BACK)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box(wizard_mob), SLOT_IN_BACKPACK)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(wizard_mob), SLOT_R_STORE)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/spellbook(wizard_mob), SLOT_R_HAND)

	to_chat(wizard_mob, "<span class='info'>You will find a list of available spells in your spell book. Choose your magic arsenal carefully.</span>")
	to_chat(wizard_mob, "<span class='info'>In your pockets you will find a teleport scroll. Use it as needed.</span>")
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	wizard_mob.update_icons()

/datum/role/wizard/OnPostSetup(laterole)
	. = ..()
	equip_wizard(antag.current)
	INVOKE_ASYNC(src, .proc/name_wizard, antag.current)

/datum/role/wizard/forgeObjectives()
	if(!..())
		return FALSE
	switch(rand(1,100))
		if(1 to 30)
			AppendObjective(/datum/objective/target/assassinate)
			AppendObjective(/datum/objective/survive)

		if(31 to 60)
			AppendObjective(/datum/objective/steal)
			AppendObjective(/datum/objective/survive)

		if(61 to 99)
			AppendObjective(/datum/objective/target/assassinate)
			AppendObjective(/datum/objective/steal)
			AppendObjective(/datum/objective/survive)

		else
			AppendObjective(/datum/objective/hijack)
	return TRUE

/datum/role/wizard/GetScoreboard()
	. = ..()
	if(antag.current && antag.current.spell_list?.len)
		. += "<br><b>[antag.name] used the following spells: </b>"
		var/i = 1
		for(var/obj/effect/proc_holder/spell/S in antag.current.spell_list)
			var/icon/spellicon = icon('icons/mob/actions.dmi', S.action_icon_state)
			end_icons += spellicon
			var/tempstate = end_icons.len
			. += {"<br><img src="logo_[tempstate].png"> [S.name]"}
			if(antag.current.spell_list.len > i)
				. += ", "
			i++

/datum/role/wizard/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];wiz_tp=1;'>(Tp to base)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];wiz_name=1'>(Choose name)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];wiz_equip=1'>(Equip)</a>"
	return dat

/datum/role/wizard/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["wiz_tp"])
		M.current.forceMove(pick(wizardstart))

	else if(href_list["wiz_name"])
		INVOKE_ASYNC(src, .proc/name_wizard, M.current)

	else if(href_list["wiz_equip"])
		equip_wizard(M.current)

/datum/role/wizard_apprentice // Greets and objectives gives in code\game\gamemodes\wizard\artefact.dm
	name = WIZ_APPRENTICE
	id = WIZ_APPRENTICE

	required_pref = ROLE_WIZARD

	antag_hud_type = ANTAG_HUD_WIZ
	antag_hud_name = "hudwizard"

	logo_state = "wizard-logo"

/datum/role/wizard_apprentice/GetScoreboard()
	. = ..()
	if(antag.current && antag.current.spell_list?.len)
		. += "<br><b>[antag.name] used the following spells: </b>"
		var/i = 1
		for(var/obj/effect/proc_holder/spell/S in antag.current.spell_list)
			var/icon/spellicon = icon('icons/mob/actions.dmi', S.action_icon_state)
			end_icons += spellicon
			var/tempstate = end_icons.len
			. += {"<br><img src="logo_[tempstate].png"> [S.name]"}
			if(antag.current.spell_list.len > i)
				. += ", "
			i++
