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
	skill_sets = list(
		"Test Subject"   = /datum/skills_modifier/test_subject,
		"Lawyer"         = /datum/skills_modifier/test_subject/lawyer,
		"Mecha Operator" = /datum/skills_modifier/test_subject/mecha,
		"Private Eye"    = /datum/skills_modifier/test_subject/detective,
		"Reporter"       = /datum/skills_modifier/test_subject/reporter,
		"Waiter"         = /datum/skills_modifier/test_subject/waiter,
		"Vice Officer"   = /datum/skills_modifier/test_subject/vice_officer,
		"Paranormal Investigator" = /datum/skills_modifier/test_subject/paranormal
		)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
