/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/medGold
	req_admin_notify = 1
	is_head = TRUE
	access = list(
		access_medical, access_morgue, access_paramedic, access_genetics, access_heads,
		access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
		access_keycard_auth, access_sec_doors, access_psychiatrist, access_maint_tunnels,
		access_medbay_storage
	)
	salary = 250
	minimal_player_age = 10
	minimal_player_ingame_minutes = 2400
	outfit = /datum/outfit/job/cmo
	skillsets = list("Chief Medical Officer" = /datum/skillset/cmo)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(UNATHI, TAJARAN, VOX, DIONA)

	department_stocks = list("Medical" = 40)
	flags = JOB_FLAG_COMMAND|JOB_FLAG_HEAD_OF_STAFF|JOB_FLAG_MEDBAY|JOB_FLAG_BLUESHIELD_PROTEC

/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_surgery, access_maint_tunnels, access_medbay_storage)
	salary = 160
	alt_titles = list(
		"Surgeon" = /datum/outfit/job/surgeon,
		"Nurse" = /datum/outfit/job/nurse
		)
	minimal_player_ingame_minutes = 960
	outfit = /datum/outfit/job/doctor
	skillsets = list(
		"Medical Doctor" = /datum/skillset/doctor,
		"Surgeon" = /datum/skillset/doctor/surgeon,
		"Nurse" = /datum/skillset/doctor/nurse
		)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(UNATHI, DIONA)

	department_stocks = list("Medical" = 20)
	flags = JOB_FLAG_MEDBAY

/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_paramedic, access_maint_tunnels, access_external_airlocks, access_sec_doors, access_research, access_medbay_storage, access_engineering_lobby)
	salary = 120
	minimal_player_ingame_minutes = 1500 //they have too much access, so you have to play more to unlock it
	outfit = /datum/outfit/job/paramedic
	skillsets = list("Paramedic" = /datum/skillset/paramedic)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/

	department_stocks = list("Medical" = 15)
	flags = JOB_FLAG_MEDBAY

	restricted_species = list(DIONA)// Slow species shouldn't be paramedics.

//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_chemistry, access_medbay_storage)
	salary = 150
	alt_titles = list("Pharmacist")
	minimal_player_ingame_minutes = 960
	outfit = /datum/outfit/job/chemist
	skillsets = list("Chemist" = /datum/skillset/chemist)

	department_stocks = list("Medical" = 10)
	flags = JOB_FLAG_MEDBAY

/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_genetics, access_research, access_medbay_storage)
	salary = 180
	minimal_player_ingame_minutes = 960
	outfit = /datum/outfit/job/geneticist
	skillsets = list("Geneticist" = /datum/skillset/geneticist)

	department_stocks = list("Medical" = 10)
	flags = JOB_FLAG_MEDBAY

/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_virology, access_medbay_storage)
	alt_titles = list("Pathologist","Microbiologist")
	minimal_player_ingame_minutes = 960
	salary = 180
	outfit = /datum/outfit/job/virologist
	skillsets = list("Virologist" = /datum/skillset/virologist)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(UNATHI)

	department_stocks = list("Medical" = 10)
	flags = JOB_FLAG_MEDBAY

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_psychiatrist, access_medbay_storage)
	alt_titles = list("Psychologist" = /datum/outfit/job/psychologist)
	salary = 140
	minimal_player_ingame_minutes = 960
	outfit = /datum/outfit/job/psychiatrist
	skillsets = list("Psychiatrist" = /datum/skillset/psychiatrist)

	restricted_species = list(UNATHI)

	department_stocks = list("Medical" = 10)
	flags = JOB_FLAG_MEDBAY

/datum/job/intern
	title = "Medical Intern"
	flag = INTERN
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical)
	salary = 50
	outfit = /datum/outfit/job/intern
	skillsets = list("Medical Intern" = /datum/skillset/intern)

	department_stocks = list("Medical" = 5)
	flags = JOB_FLAG_MEDBAY
