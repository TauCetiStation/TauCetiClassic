/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	salary = 300
	minimal_player_age = 14
	minimal_player_ingame_minutes = 3900
	outfit = /datum/outfit/job/captain

// Non-human species can't be captains.
/datum/job/captain/special_species_check(datum/species/S)
	return S.name == HUMAN

/datum/job/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		to_chat(world, "<b>[H.real_name] is the captain!</b>")//maybe should be announcment, not OOC notification?
		score["captain"] += H.real_name

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	salary = 250
	minimal_player_age = 10
	minimal_player_ingame_minutes = 2400
	access = list(
		access_security, access_sec_doors, access_brig, access_forensics_lockers,
		access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
		access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
		access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
		access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
		access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_recycler, access_detective, access_barber
	)
	outfit = /datum/outfit/job/hop
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, VOX, IPC)
