/datum/job/blueshield
	title = "Blueshield Officer"
	flag = BLUESHIELD
	department_flag = CENTCOMREPRESENT
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "The Central Command"
	selection_color = "#6c7391"
	idtype = /obj/item/weapon/card/id/blueshield
	access = list(access_blueshield, access_heads, access_maint_tunnels,
				  access_sec_doors, access_medical, access_research, access_mailsorting, access_engineering_lobby,
				  access_security, access_engine) // needed accesses to reach heads
	salary = 200
	minimal_player_age = 14
	minimal_player_ingame_minutes = 2400
	outfit = /datum/outfit/job/blueshield
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, VOX, IPC)
	skillsets = list("Blueshield Officer" = /datum/skillset/blueshield)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	flags = JOB_FLAG_CENTCOMREPRESENTATIVE

/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = CENTCOMREPRESENT
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "The Central Command"
	selection_color = "#6c7391"
	idtype = /obj/item/weapon/card/id/int
	access = list(access_lawyer, access_sec_doors, access_medical, access_research, access_mailsorting, access_engineering_lobby)
	salary = 200
	minimal_player_ingame_minutes = 1560
	outfit = /datum/outfit/job/lawyer
	skillsets = list("Internal Affairs Agent" = /datum/skillset/internal_affairs)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, VOX, IPC)
	flags = JOB_FLAG_CENTCOMREPRESENTATIVE|JOB_FLAG_BLUESHIELD_PROTEC
