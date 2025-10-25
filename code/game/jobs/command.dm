/datum/department/command
	title = DEP_COMMAND
	head = JOB_CAPTAIN
	order = 1
	color = "#aac1ee"

/datum/job/captain
	title = JOB_CAPTAIN
	departments = list(DEP_COMMAND)
	order = CREW_INTEND_HEADS(1)
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
	skillsets = list("Captain" = /datum/skillset/captain)

// Non-human species can't be captains.
/datum/job/captain/special_species_check(datum/species/S)
	return S.name == HUMAN

/datum/job/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		to_chat(world, "<b>[H.real_name] новый капитан!</b>")//maybe should be announcment, not OOC notification?
		SSStatistics.score.captain += H.real_name

/datum/job/captain/get_access()
	return get_all_accesses()
