/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = 1
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400
	give_loadout_items = FALSE

/datum/job/ai/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0

	if(visualsOnly)
		return

	return 1

/datum/job/ai/is_position_available()
	return (empty_playable_ai_cores.len != 0)


/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0 // Not used for AI, see is_position_available below and modules/mob/living/silicon/ai/latejoin.dm
	spawn_positions = 2
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 1
	alt_titles = list("Android", "Robot")
	minimal_player_ingame_minutes = 1800
	give_loadout_items = FALSE

/datum/job/cyborg/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0

	if(visualsOnly)
		return

	return 1
