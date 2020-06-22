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
	alt_titles = list("Lawyer","Mecha Operator","Private Eye","Reporter","Waiter","Vice Officer","Paranormal Investigator")

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0
	if(visualsOnly)
		H.equipOutfit(/datum/outfit/job/assistant, visualsOnly)
		return
	if(H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Lawyer")
				H.equipOutfit(/datum/outfit/job/assistant/lawyer, visualsOnly)
			if("Mecha Operator")
				H.equipOutfit(/datum/outfit/job/assistant/mecha_operator, visualsOnly)
			if("Private Eye")
				H.equipOutfit(/datum/outfit/job/assistant/private_eye, visualsOnly)
			if("Reporter")
				to_chat(world, "REPORTER, oof")
				H.equipOutfit(/datum/outfit/job/assistant/reporter, visualsOnly)
			if("Security Cadet")
				H.equipOutfit(/datum/outfit/job/assistant/security_cadet, visualsOnly)
			if("Test Subject")
				H.equipOutfit(/datum/outfit/job/assistant/test_subject, visualsOnly)
			if("Waiter")
				H.equipOutfit(/datum/outfit/job/assistant/waiter, visualsOnly)
			if("Vice Officer")
				H.equipOutfit(/datum/outfit/job/assistant/vice_officer, visualsOnly)
			if("Paranormal Investigator")
				H.equipOutfit(/datum/outfit/job/assistant/paranormal_investigator, visualsOnly)

	return TRUE

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
