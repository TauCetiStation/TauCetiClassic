/datum/objective/evolution
	explanation_text = "Достигните шестого этапа эволюции."

/datum/objective/evolution/check_completion()
	var/mob/living/carbon/xenomorph/humanoid/hunter/lone/alien = owner
	if(alien && istype(alien))
		if(alien.estage >= 6)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//		NOSTROMO MAP MODULE OBJECTIVES
/datum/objective/nostromo
	var/datum/map_module/alien/MM = null

/datum/objective/nostromo/New()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)

//		KILL CREW FOR AIEN
/datum/objective/nostromo/bloodbath
	explanation_text = "Убейте всех людей на корабле."

/datum/objective/nostromo/bloodbath/check_completion()
	if(MM && MM.deadcrew_ratio >= 90) // 90% OF THE CREW IS DEAD
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//		KILL ALIEN FOR CREW
/datum/objective/nostromo/kill_alien
	explanation_text = "Ксеноморф на корабле! Убейте эту тварь как можно скорее!"

/datum/objective/nostromo/kill_alien/check_completion()
	if(MM && !MM.alien_alive)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//		DEFEND ALIEN FOR ANDROID
/datum/objective/nostromo/defend_alien
	explanation_text = "Ксеноморф должен выжить."

/datum/objective/nostromo/defend_alien/check_completion()
	if(MM && MM.alien_alive)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//		DEFEND CREW FOR CAPTAIN
/datum/objective/nostromo/defend_crew
	explanation_text = "Сведите потери среди экипажа к минимуму."

/datum/objective/nostromo/defend_crew/check_completion()
	if(MM && MM.deadcrew_ratio < 30) // 70% OF THE CREW IS ALIVE
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//		DEFEND SHIP FOR ANDROID
/datum/objective/nostromo/defend_ship
	explanation_text = "Корабль должен остаться в рабочем состоянии."

/datum/objective/nostromo/defend_ship/check_completion()
	if(MM && !MM.breakdown)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
