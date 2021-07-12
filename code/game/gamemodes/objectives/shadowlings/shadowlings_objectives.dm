/datum/objective/enthrall
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with 15 collective thralls, while hatched, and is unlocked with the Collective Mind ability."

/datum/objective/enthrall/check_completion()
	var/datum/faction/shadowlings/S = faction
	return istype(S) && S.shadowling_ascended
