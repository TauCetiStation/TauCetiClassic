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
	skillsets = list(
		"Test Subject"   = /datum/skillset/test_subject,
		"Lawyer"         = /datum/skillset/test_subject/lawyer,
		"Mecha Operator" = /datum/skillset/test_subject/mecha,
		"Private Eye"    = /datum/skillset/test_subject/detective,
		"Reporter"       = /datum/skillset/test_subject/reporter,
		"Waiter"         = /datum/skillset/test_subject/waiter,
		"Vice Officer"   = /datum/skillset/test_subject/vice_officer,
		"Paranormal Investigator" = /datum/skillset/test_subject/paranormal
		)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
