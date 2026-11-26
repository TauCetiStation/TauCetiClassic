/datum/role/relative
	name = RELATIVE
	id = RELATIVE

	restricted_jobs = list("AI", "Cyborg", "Head of Security", "Captain", "Internal Affairs Agent", "Blueshield Officer")

	antag_hud_type = HUD_RELATIVE_1
	antag_hud_name = "hud_family_1"

/datum/role/relative/OnPreSetup()
	. = ..()
	var/datum/faction/relatives/F = faction
	if(!istype(F))
		return

	logo_state = "family_[F.relatives_id]"
	switch(F.relatives_id)
		if(1)
			antag_hud_type = HUD_RELATIVE_1
		if(2)
			antag_hud_type = HUD_RELATIVE_2
		if(3)
			antag_hud_type = HUD_RELATIVE_3
	antag_hud_name = "hud_family_[F.relatives_id]"

/datum/role/relative/add_antag_hud(custom_name)
	..()
	var/datum/atom_hud/antag/hud = global.huds[antag_hud_type]
	hud.hide_single_atomhud_from(antag.current, antag.current)

/datum/role/relative/Greet(laterole)
	return

/datum/role/relative/extraPanelButtons()
	return

/datum/role/relative/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	return

/datum/role/relative/AnnounceObjectives()
	return
