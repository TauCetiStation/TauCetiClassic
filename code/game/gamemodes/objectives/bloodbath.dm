/datum/objective/bloodbath
	explanation_text = "Убейте всех людей на корабле."

/datum/objective/reproduct/check_completion()
	var/datum/faction/alien/F = find_faction_by_type(/datum/faction/alien)
	if(F && F.check_crew(for_alien = TRUE))
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/kill_alien
	explanation_text = "Ксеноморф на корабле! Убейте эту тварь как можно скорее!"

/datum/objective/kill_alien/check_completion()
	var/list/lhlist = global.alien_list[ALIEN_LONE_HUNTER]
	if(!lhlist.len)
		return OBJECTIVE_WIN
	var/mob/living/L = lhlist[1]
	if(L)
		if(L.stat == DEAD)
			return OBJECTIVE_WIN
		else
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/defend_alien
	explanation_text = "Ксеноморф должен выжить."

/datum/objective/defend_alien/check_completion()
	var/list/lhlist = global.alien_list[ALIEN_LONE_HUNTER]
	if(!lhlist.len)
		return OBJECTIVE_LOSS
	var/mob/living/L = lhlist[1]
	if(L)
		if(L.stat == DEAD)
			return OBJECTIVE_LOSS
		else
			var/mob/M = owner.current  // если ксеноморф жив, а андроид нет, то халфвин
			if(!owner.current || ((owner.current.stat == DEAD) && !M.fake_death) || isbrain(owner.current))
				return OBJECTIVE_HALFWIN
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/defend_crew
	explanation_text = "Сведите потери среди экипажа к минимуму."

/datum/objective/defend_crew/check_completion()
	var/datum/faction/alien/F = find_faction_by_type(/datum/faction/nostromo_crew)
	if(F && F.check_crew() <= (human_list.len / 2))
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
