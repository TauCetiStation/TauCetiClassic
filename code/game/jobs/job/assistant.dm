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
	salary = 20
	alt_titles = list(
		"Lawyer"         = /datum/outfit/job/assistant/lawyer,
		"Mecha Operator" = /datum/outfit/job/assistant/mecha_operator,
		"Private Eye"    = /datum/outfit/job/assistant/private_eye,
		"Reporter"       = /datum/outfit/job/assistant/reporter,
		"Waiter"         = /datum/outfit/job/assistant/waiter,
		"Vice Officer"   = /datum/outfit/job/assistant/vice_officer,
		"Paranormal Investigator" = /datum/outfit/job/assistant/paranormal_investigator
		)
	outfit = /datum/outfit/job/assistant/test_subject
	skills_type = /datum/skills/test_subject
	alt_skills_types = list(
		"Lawyer"         = /datum/skills/test_subject/lawyer,
		"Mecha Operator" = /datum/skills/test_subject/mecha,
		"Private Eye"    = /datum/skills/test_subject/detective,
		"Reporter"       = /datum/skills/test_subject/reporter,
		"Waiter"         = /datum/skills/test_subject/waiter,
		"Vice Officer"   = /datum/skills/test_subject/vice_officer,
		"Paranormal Investigator" = /datum/skills/test_subject/paranormal
		)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
