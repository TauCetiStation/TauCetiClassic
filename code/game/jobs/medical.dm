/datum/department/medical
	title = DEP_MEDICAL
	head = JOB_CMO
	order = 5
	color = "#99ffe6"

/datum/job/cmo
	title = JOB_CMO
	departments = list(DEP_MEDICAL, DEP_COMMAND)
	order = CREW_INTEND_HEADS(6)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/medGold
	req_admin_notify = 1
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

/datum/job/doctor
	title = JOB_DOCTOR
	departments = list(DEP_MEDICAL)
	order = CREW_INTEND_EMPLOYEE(1)
	title = "Medical Doctor"
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

/datum/job/paramedic
	title = JOB_PARAMEDIC
	departments = list(DEP_MEDICAL)
	order = CREW_INTEND_EMPLOYEE(2)
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

	restricted_species = list(DIONA)// Slow species shouldn't be paramedics.

/datum/job/chemist
	title = JOB_CHEMIST
	departments = list(DEP_MEDICAL)
	order = CREW_INTEND_EMPLOYEE(3)
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

/datum/job/geneticist
	title = JOB_GENETICIST
	departments = list(DEP_MEDICAL, DEP_SCIENCE)
	order = CREW_INTEND_EMPLOYEE(4)
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

/datum/job/virologist
	title = JOB_VIROLOGIST
	departments = list(DEP_MEDICAL)
	order = CREW_INTEND_EMPLOYEE(5)
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

/datum/job/psychiatrist
	title = JOB_PSYCHIATRIST
	departments = list(DEP_MEDICAL)
	order = CREW_INTEND_EMPLOYEE(6)
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

/datum/job/intern
	title = JOB_INTERN
	departments = list(DEP_MEDICAL)
	order = CREW_INTEND_ASSIST(1)
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
