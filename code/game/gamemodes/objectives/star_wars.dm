/datum/objective/star_wars/convert
	var/member_needed

/datum/objective/star_wars/convert/New()
	member_needed = max(4, round(player_list.len * 0.3))
	explanation_text = "Орден должен расти, переманите на свою сторону [member_needed] [pluralize_russian(member_needed, "человека", "человека", "человек")]."
	..()

/datum/objective/star_wars/convert/check_completion()
	if(faction.members.len >= member_needed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/star_wars/jedi
	explanation_text = "Разгромите орден ситхов. Переманите их на светлую сторону силы или убейте."

/datum/objective/star_wars/jedi/check_completion()
	var/datum/faction/F = find_faction_by_type(/datum/faction/star_wars/sith)
	if(F.members.len <= 1)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/star_wars/sith
	explanation_text = "Разгромите орден джедаев. Переманите их на тёмную сторону силы или убейте."

/datum/objective/star_wars/sith/check_completion()
	var/datum/faction/F = find_faction_by_type(/datum/faction/star_wars/jedi)
	if(F.members.len <= 1)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS