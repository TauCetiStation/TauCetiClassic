/datum/objective/blob_takeover
	explanation_text = "We must grow and expand. Fill this station with our spores. Cover X station tiles."
	var/invade_tiles = 0

/datum/objective/blob_takeover/PostAppend()
	..()
	var/datum/faction/blob_conglomerate/F = faction
	if (!istype(F))
		return FALSE
	invade_tiles = F.blobwincount
	explanation_text = "We must grow and expand. Fill this station with our spores. Cover [invade_tiles] station tiles."
	return TRUE

/datum/objective/blob_takeover/check_completion()
	if(blobs.len >= invade_tiles * 0.95)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
