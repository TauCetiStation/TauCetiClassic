/datum/spoken_info
	var/atom/hearer
	var/atom/speaker
	var/message
	var/alt_name
	var/spoken_verb
	var/message_range
	var/datum/language/spoken

/datum/spoken_info/New(atom/hearer, message, speaker = null, spoken_verb = "says", datum/language/spoken = null, alt_name = "", message_range = world.view)
	src.hearer = hearer
	src.message = message
	src.speaker = speaker
	src.spoken_verb = spoken_verb
	src.spoken = spoken
	src.alt_name = alt_name
	src.message_range = message_range

/datum/spoken_info/proc/merge(datum/spoken_info/new_info, force = FALSE)
	if(isnull(message) || (!isnull(new_info.message) && force))
		message = new_info.message
	if(!speaker || (new_info.speaker && force))
		speaker = new_info.speaker
	if(spoken_verb == "says" || (new_info.spoken_verb != "says" && force))
		spoken_verb = new_info.spoken_verb
	if(!spoken || (new_info.spoken && force))
		spoken = new_info.spoken
	if(alt_name == "" || (new_info.alt_name != "" && force))
		alt_name = new_info.alt_name
	if(message_range == world.view || (new_info.message_range != world.view && force))
		message_range = new_info.message_range

/datum/spoken_info/proc/copy()
	return new /datum/spoken_info(hearer, message, speaker, spoken_verb, spoken, alt_name, message_range)

/datum/spoken_info/Destroy()
	speaker = null
	spoken = null
	return ..()
