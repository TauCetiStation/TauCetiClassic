/datum/job/assistant
	title = "Assistant"
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
		"Test Subject"   = /datum/outfit/job/assistant/test_subject,
		"Lawyer"         = /datum/outfit/job/assistant/lawyer,
		"Private Eye"    = /datum/outfit/job/assistant/private_eye,
		"Reporter"       = /datum/outfit/job/assistant/reporter,
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
		"Reporter"       = /datum/skillset/assistant/reporter,
		"Waiter"         = /datum/skillset/assistant/waiter,
		"Vice Officer"   = /datum/skillset/assistant/vice_officer,
		"Paranormal Investigator" = /datum/skillset/assistant/paranormal
		)
	flags = JOB_FLAG_CIVIL

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
