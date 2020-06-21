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
	H.equipOutfit(/datum/outfit/job/assistant, visualsOnly)
	if(visualsOnly)
		return

	return TRUE

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
