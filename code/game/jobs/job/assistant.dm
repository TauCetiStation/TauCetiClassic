/datum/job/assistant
	title = "Clown Candidate"
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
		"Clown Lawyer"         = /datum/outfit/job/assistant/lawyer,
		"Private Clown"    	   = /datum/outfit/job/assistant/private_eye,
		"Clown Reporter"       = /datum/outfit/job/assistant/reporter,
		"Clown Waiter"         = /datum/outfit/job/assistant/waiter,
		"Clown Vice Officer"   = /datum/outfit/job/assistant/vice_officer,
		"Paranormal Clown"     = /datum/outfit/job/assistant/paranormal_investigator
		)
	outfit = /datum/outfit/job/assistant/test_subject

/datum/job/assistant/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.mutations |= CLUMSY

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
