/datum/department/science
	title = DEP_SCIENCE
	head = JOB_RD
	order = 6
	color = "#e6b3e6"

/datum/job/rd
	title = JOB_RD
	departments = list(DEP_SCIENCE, DEP_COMMAND)
	order = CREW_INTEND_HEADS(5)
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
		access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway,
		access_xenoarch, access_maint_tunnels, access_eva
	)
	salary = 250
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400
	skillsets = list("Research Director" = /datum/skillset/rd)
	outfit = /datum/outfit/job/rd
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(UNATHI, TAJARAN, VOX, DIONA)

/datum/job/scientist
	title = JOB_SCIENTIST
	departments = list(DEP_SCIENCE)
	order = CREW_INTEND_EMPLOYEE(1)
	total_positions = 3
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
	alt_titles = list("Phoron Researcher")
	salary = 180
	minimal_player_ingame_minutes = 1560
	outfit = /datum/outfit/job/scientist
	skillsets = list(
		"Scientist" = /datum/skillset/scientist,
		"Phoron Researcher" = /datum/skillset/scientist/phoron
		)

/datum/job/xenoarchaeologist
	title = JOB_XENOARCHAEOLOGIST
	departments = list(DEP_SCIENCE)
	order = CREW_INTEND_EMPLOYEE(2)
	total_positions = 3
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research, access_xenoarch)
	salary = 190
	minimal_player_ingame_minutes = 1400
	outfit = /datum/outfit/job/xenoarchaeologist
	skillsets = list("Xenoarchaeologist" = /datum/skillset/xenoarchaeologist)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/

/datum/job/xenobiologist
	title = JOB_XENOBIOLOGIST
	departments = list(DEP_SCIENCE)
	order = CREW_INTEND_EMPLOYEE(3)
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research, access_xenobiology)
	salary = 190
	minimal_player_ingame_minutes = 1560
	outfit = /datum/outfit/job/xenobiologist
	skillsets = list("Xenobiologist" = /datum/skillset/xenobiologist)

/datum/job/roboticist
	title = JOB_ROBOTICIST
	departments = list(DEP_SCIENCE)
	order = CREW_INTEND_EMPLOYEE(4)
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_robotics, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	salary = 180
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_ingame_minutes = 1560
	outfit = /datum/outfit/job/roboticist
	skillsets = list(
		"Roboticist" = /datum/skillset/roboticist,
		"Biomechanical Engineer" = /datum/skillset/roboticist/bio,
		"Mechatronic Engineer" = /datum/skillset/roboticist/mecha
	)

/datum/job/research_assistant
	title = JOB_RESEARCH_ASSISTANT
	departments = list(DEP_SCIENCE)
	order = CREW_INTEND_ASSIST(1)
	total_positions = 3
	spawn_positions = 3
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research)
	salary = 50
	outfit = /datum/outfit/job/research_assistant
	skillsets = list("Research Assistant" = /datum/skillset/research_assistant)
