/datum/department/engineering
	title = DEP_ENGINEERING
	head = JOB_CHIEF_ENGINEER
	order = 4
	color = "#ffd699"

/datum/job/chief_engineer
	title = JOB_CHIEF_ENGINEER
	departments = list(DEP_ENGINEERING, DEP_COMMAND)
	order = CREW_INTEND_HEADS(4)
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/engGold
	req_admin_notify = 1
	access = list(
		access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
		access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
		access_heads, access_construction, access_sec_doors, access_minisat,
		access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload, access_engineering_lobby
	)
	salary = 250
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400
	outfit = /datum/outfit/job/chief_engineer
	skillsets = list("Chief Engineer" = /datum/skillset/ce)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(TAJARAN, VOX, DIONA)

/datum/job/engineer
	title = JOB_ENGINEER
	departments = list(DEP_ENGINEERING)
	order = CREW_INTEND_EMPLOYEE(1)
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_engineering_lobby)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")
	outfit = /datum/outfit/job/engineer
	skillsets = list("Station Engineer" = /datum/skillset/engineer)
	salary = 160
	minimal_player_age = 3
	minimal_player_ingame_minutes = 540

/datum/job/atmos
	title = JOB_ATMOS
	departments = list(DEP_ENGINEERING)
	order = CREW_INTEND_EMPLOYEE(2)
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction, access_external_airlocks, access_engineering_lobby)
	salary = 160
	minimal_player_age = 3
	minimal_player_ingame_minutes = 600
	outfit = /datum/outfit/job/atmos
	skillsets = list("Atmospheric Technician" = /datum/skillset/atmostech)

/datum/job/technical_assistant
	title = JOB_TECHNICAL_ASSISTANT
	departments = list(DEP_ENGINEERING)
	order = CREW_INTEND_ASSIST(1)
	total_positions = 3
	spawn_positions = 3
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_engineering_lobby, access_construction, access_maint_tunnels)
	salary = 50
	outfit = /datum/outfit/job/technical_assistant
	skillsets = list("Technical Assistant" = /datum/skillset/technicassistant)

/proc/get_airlock_wires_identification()
	var/list/wire_list = same_wires[/obj/machinery/door/airlock]
	var/list/wire_functions_list = list(
		"[AIRLOCK_WIRE_IDSCAN]"      = "ID scan",
		"[AIRLOCK_WIRE_MAIN_POWER1]" = "main power",
		"[AIRLOCK_WIRE_MAIN_POWER2]" = "backup power",
		"[AIRLOCK_WIRE_DOOR_BOLTS]"  = "door Bolts",
		"[AIRLOCK_WIRE_OPEN_DOOR]"   = "open door",
		"[AIRLOCK_WIRE_AI_CONTROL]"  = "ai control",
		"[AIRLOCK_WIRE_ELECTRIFY]"   = "electrify",
		"[AIRLOCK_WIRE_SAFETY]"      = "door safety",
		"[AIRLOCK_WIRE_SPEED]"       = "timing mechanism",
		"[AIRLOCK_WIRE_LIGHT]"       = "bolt light",
		"[AIRLOCK_WIRE_UNRES_SIDE]"  = "unrestricted sides"
	)

	var/info = ""

	for(var/wire in wire_list)
		var/current_wire_index = wire_list[wire]
		var/current_wire_function = wire_functions_list["[current_wire_index]"]

		if(current_wire_function)
			info += "[capitalize(wire)] wire is [current_wire_function].<br>"

	return info
