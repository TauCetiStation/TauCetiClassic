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
	skillsets = list("Test Subject" = /datum/skillset/test_subject)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE, alt_title)
    . = ..()
    if(!.)
        return

    if(!H.mind)
        return

    H.mind.skills.add_unique_available_skillset(new /datum/skillset/random())
    H.mind.skills.maximize_active_skills()
