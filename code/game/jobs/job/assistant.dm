/datum/job/assistant
	title = "Test Subject"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	salary = 0
	alt_titles = list(
		"Lawyer"         = /datum/outfit/job/assistant/lawyer,
		"Private Eye"    = /datum/outfit/job/assistant/private_eye,
		"Reporter"       = /datum/outfit/job/assistant/reporter,
		"Waiter"         = /datum/outfit/job/assistant/waiter,
		"Vice Officer"   = /datum/outfit/job/assistant/vice_officer,
		"Paranormal Investigator" = /datum/outfit/job/assistant/paranormal_investigator
		)
	outfit = /datum/outfit/job/assistant/test_subject
	skillsets = list("Test Subject"   = /datum/skillset/test_subject)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE, alt_title)
	if(!H)
		return FALSE

	var/outfit_type = get_outfit(H, alt_title)
	if(outfit_type)
		H.equipOutfit(outfit_type, visualsOnly)

	for(var/moveset in moveset_types)
		H.add_moveset(new moveset(), MOVESET_JOB)

	if (H.mind)
		H.mind.skills.add_available_skillset(get_skillset(H))
		for(var/datum/skillset/s as anything in H.mind.skills.available_skillsets)
			s.randomize()
	..()
