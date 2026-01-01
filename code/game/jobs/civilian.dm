/datum/department/civilian
	title = DEP_CIVILIAN
	head = JOB_HOP
	order = 10
	color = "#cccccc"

/datum/job/hop
	title = JOB_HOP
	departments = list(DEP_CIVILIAN, DEP_COMMAND)
	order = CREW_INTEND_HEADS(2)
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
		access_medical, access_change_ids, access_ai_upload, access_eva, access_heads,
		access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
		access_crematorium, access_kitchen, access_cargo, access_cargoshop, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
		access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
		access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_recycler, access_detective, access_barber
	)
	outfit = /datum/outfit/job/hop
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(UNATHI, TAJARAN, DIONA, VOX)
	skillsets = list("Head of Personnel" = /datum/skillset/hop)

//Cargo
/datum/job/qm
	title = JOB_QM
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(1)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargoGold
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargoshop, access_qm, access_mint, access_mining, access_mining_station, access_recycler)
	salary = 0
	starting_money = 60
	minimal_player_ingame_minutes = 960
	outfit = /datum/outfit/job/qm
	skillsets = list("Quartermaster" = /datum/skillset/quartermaster)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(TAJARAN, VOX, DIONA)

	department_stocks = list("Cargo" = 40)

/datum/job/qm/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		SSeconomy.add_account_knowledge(H, "Cargo")

/datum/job/cargo_tech
	title = JOB_CARGO_TECH
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(2)
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_maint_tunnels, access_cargo, access_cargoshop, access_mailsorting)
	salary = 0
	starting_money = 25
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/cargo_tech
	skillsets = list("Cargo Technician" = /datum/skillset/cargotech)

	department_stocks = list("Cargo" = 20)

/datum/job/mining
	title = JOB_MINER
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(3)
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_mining, access_mint, access_mining_station, access_mailsorting)
	salary = 0
	starting_money = 30
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/mining
	skillsets = list("Shaft Miner" = /datum/skillset/miner)

	department_stocks = list("Cargo" = 10)

/datum/job/recycler
	title = JOB_RECYCLER
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(4)
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_mailsorting, access_recycler)
	salary = 0
	starting_money = 20
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/recycler
	skillsets = list("Recycler" = /datum/skillset/recycler)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/

	department_stocks = list("Cargo" = 10)

//Food
/datum/job/bartender
	title = JOB_BARTENDER
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(5)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_bar)
	salary = 40
	minimal_player_ingame_minutes = 240
	outfit = /datum/outfit/job/bartender
	skillsets = list("Bartender" = /datum/skillset/bartender)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/

/datum/job/chef
	title = JOB_CHEF
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(6)
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_kitchen)
	salary = 40
	alt_titles = list("Cook")
	minimal_player_ingame_minutes = 240
	outfit = /datum/outfit/job/chef
	skillsets = list("Chef" = /datum/skillset/chef)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/

/datum/job/chef/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		new /obj/item/weapon/implant/bork(H)
	return ..()

/datum/job/hydro
	title = JOB_HYDRO
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(7)
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_hydroponics) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	salary = 60
	alt_titles = list("Hydroponicist")
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/hydro
	skillsets = list("Botanist" = /datum/skillset/botanist)

/datum/job/janitor
	title = JOB_JANITOR
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(8)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_janitor, access_maint_tunnels, access_sec_doors, access_research, access_mailsorting, access_medical, access_engineering_lobby)
	salary = 50
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/janitor
	skillsets = list("Janitor" = /datum/skillset/janitor)

//More or less assistants
/datum/job/barber
	title = JOB_BARBER
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(9)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_barber)
	salary = 40
	alt_titles = list("Stylist" = /datum/outfit/job/stylist)
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/barber
	skillsets = list("Barber" = /datum/skillset/barber)

/datum/job/librarian
	title = JOB_LIBRARIAN
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(10)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_library)
	salary = 40
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/librarian
	skillsets = list("Librarian" = /datum/skillset/librarian)

/datum/job/clown
	title = JOB_CLOWN
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(11)
	title = "Clown"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/clown
	access = list(access_clown, access_theatre)
	salary = 20
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/clown
	skillsets = list("Clown" = /datum/skillset/clown)
	restricted_species = list(SKRELL)

/datum/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		ADD_TRAIT(H, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)
	H.real_name = pick(clown_names)
	H.rename_self("clown")

/datum/job/mime
	title = JOB_MIME
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(12)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/mime
	access = list(access_mime, access_theatre)
	salary = 20
	outfit = /datum/outfit/job/mime
	skillsets = list("Mime" = /datum/skillset/mime)

/datum/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		H.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/mimewall)
		H.AddSpell(new /obj/effect/proc_holder/spell/no_target/mime_speak)
		ADD_TRAIT(H, TRAIT_MIMING, GENERIC_TRAIT)
	H.real_name = pick(mime_names)
	H.rename_self("mime")

//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = JOB_CHAPLAIN
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(13)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_morgue, access_chapel_office, access_crematorium)
	salary = 40
	alt_titles = list("Counselor")
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/chaplain
	skillsets = list("Chaplain" = /datum/skillset/chaplain)
	restricted_species = list(PLUVIAN)

/datum/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly && H.mind)
		INVOKE_ASYNC(global.chaplain_religion, TYPE_PROC_REF(/datum/religion/chaplain, create_by_chaplain), H)

/datum/job/assistant
	title = JOB_ASSISTANT
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_ASSIST(1)
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	salary = 0
	alt_titles = list(
		"Test Subject"   = /datum/outfit/job/assistant/test_subject,
		"Lawyer"         = /datum/outfit/job/assistant/lawyer,
		"Private Eye"    = /datum/outfit/job/assistant/private_eye,
		"Journalist"     = /datum/outfit/job/assistant/journalist,
		"Waiter"         = /datum/outfit/job/assistant/waiter,
		"Vice Officer"   = /datum/outfit/job/assistant/vice_officer,
		"Paranormal Investigator" = /datum/outfit/job/assistant/paranormal_investigator
		)
	outfit = /datum/outfit/job/assistant
	skillsets = list(
		"Assistant"      = /datum/skillset/assistant,
		"Test Subject"   = /datum/skillset/assistant/test_subject,
		"Lawyer"         = /datum/skillset/assistant/lawyer,
		"Mecha Operator" = /datum/skillset/assistant/mecha,
		"Private Eye"    = /datum/skillset/assistant/detective,
		"Journalist"     = /datum/skillset/assistant/journalist,
		"Waiter"         = /datum/skillset/assistant/waiter,
		"Vice Officer"   = /datum/skillset/assistant/vice_officer,
		"Paranormal Investigator" = /datum/skillset/assistant/paranormal
		)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
