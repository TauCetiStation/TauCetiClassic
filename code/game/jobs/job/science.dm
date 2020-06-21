/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	idtype = /obj/item/weapon/card/id/sciGold
	req_admin_notify = 1
	access = list(
		access_rd, access_heads, access_tox, access_genetics, access_morgue,
		access_tox_storage, access_teleporter, access_sec_doors, access_minisat,
		access_research, access_robotics, access_xenobiology, access_ai_upload,
		access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_maint_tunnels
	)
	salary = 250
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(UNATHI, TAJARAN, VOX, DIONA)

/datum/job/rd/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/rd, visualsOnly)
	return TRUE


/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
	alt_titles = list("Phoron Researcher")
	salary = 180
	minimal_player_ingame_minutes = 1560

/datum/job/scientist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/scientist, visualsOnly)
	return TRUE

/datum/job/xenoarchaeologist
	title = "Xenoarchaeologist"
	flag = XENOARCHAEOLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research, access_xenoarch)
	salary = 190
	minimal_player_ingame_minutes = 1400
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(IPC)

/datum/job/xenoarchaeologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/xenoarchaeologist, visualsOnly)
	return TRUE

/datum/job/xenobiologist
	title = "Xenobiologist"
	flag = XENOBIOLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research, access_xenobiology)
	salary = 190
	minimal_player_ingame_minutes = 1560

/datum/job/xenobiologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return 0
	H.equipOutfit(/datum/outfit/job/xenobiologist, visualsOnly)
	return TRUE


/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_robotics, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	salary = 180
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_ingame_minutes = 1560

/datum/job/roboticist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/roboticist, visualsOnly)
	return TRUE


/datum/job/research_assistant
	title = "Research Assistant"
	flag = RESEARCHASSISTANT
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research)
	salary = 50

/datum/job/research_assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0
	H.equipOutfit(/datum/outfit/job/research_assistant, visualsOnly)
	return TRUE
