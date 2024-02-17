/datum/objective/blob_takeover
	explanation_text = "Мы должны расти и расширяться. Заполним станцию спорами. Покроем определенное пространства станции."
	var/invade_tiles = 0

/datum/objective/blob_takeover/PostAppend()
	..()
	var/datum/faction/blob_conglomerate/F = faction
	if (!istype(F))
		return FALSE
	invade_tiles = F.blobwincount
	explanation_text = "Мы должны расти и расширяться. Заполним станцию спорами. Мы захватим [pluralize_russian(invade_tiles, "плитка", "плитки", "плиток")] для полного контроля станции."
	return TRUE

/datum/objective/blob_takeover/check_completion()
	if(blobs.len >= invade_tiles * 0.95)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
