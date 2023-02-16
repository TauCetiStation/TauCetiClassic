#define KNOWLEDGEBASE_ERROR(num, message) json_encode(list("error"=num, "message"=message))

// Returns a list of slots with given character name inside of the savefile.
/proc/character_name2slots(savefile/S, name)
	. = list()
	S.cd = "/"

	// Note: we can't know at this point whether the owner behind savefile
	// is a supporter, thus must check all slots including supporter slots.
	for(var/slot in 1 to MAX_SAVE_SLOTS_SUPPORTER)
		S.cd = "/character[slot]"
		var/character_name
		S["real_name"] >> character_name
		if(!character_name)
			continue
		if(ckey(character_name) == name)
			. += slot

// Topic format: knowledgebase&secret=secret&userid=...&ckey=ckey&name=...&index=...
// * secret - is a string representing the "password" to this endpoint. If configured, the endpoint will not provide data
//          to users without valid secret.
// * userid - is a string representing the user requesting data. Only data the user has permission to will be provided,
//          for example if a player opted out of statistics, only authorized administrators can access that player's preference file.
// * ckey - is a string representing the ckey of a player who's preference data is requested.
// * name - is a string representing the name of a character of the player who's preference data is requested.
// * index - is an integer used if the player has multiple characters with the same name to specify which of the characters to output.
/world/proc/process_knowledgebase_request(list/packed_data)
	if(!config.knowledgebase)
		return KNOWLEDGEBASE_ERROR(410, "")

	if(config.knowledgebase_secret == null)
		return KNOWLEDGEBASE_ERROR(410, "")
	if(!istext(packed_data["secret"]))
		return KNOWLEDGEBASE_ERROR(403, "Incorrect secret.")
	if(config.knowledgebase_secret != packed_data["secret"])
		return KNOWLEDGEBASE_ERROR(403, "Incorrect secret.")

	packed_data["secret"] = "SECRET"
	log_href("WTOPIC: KNOWLEDGEBASE: \"[list2params(packed_data)]\"")

	// var/userid = ckey(packed_data["userid"])
	var/ckey = ckey(packed_data["ckey"])
	if(!ckey)
		return KNOWLEDGEBASE_ERROR(400, "Missing or invalid ckey.")

	var/name = ckey(packed_data["name"])
	if(!name)
		return KNOWLEDGEBASE_ERROR(400, "Missing or invalid name.")

	var/index = sanitize_integer(text2num(packed_data["index"]), min=1, max=MAX_SAVE_SLOTS_SUPPORTER)
	if(!index)
		return KNOWLEDGEBASE_ERROR(400, "Missing or invalid index.")

	return knowledgebase_get_preferences(ckey, name, index)

/world/proc/knowledgebase_get_preferences(ckey, name, index)
	// In case the proc crashes unexpectedly.
	. = KNOWLEDGEBASE_ERROR(500, "Something went wrong when getting preference info.")

	var/path = "data/player_saves/[ckey[1]]/[ckey]/preferences.sav"
	if(!fexists(path))
		return KNOWLEDGEBASE_ERROR(404, "No preferences.sav for [ckey].")

	var/savefile/S = new /savefile(path)
	if(!S)
		return KNOWLEDGEBASE_ERROR(500, "Savefile could not be loaded.")

	var/list/slots = character_name2slots(S, name)
	if(length(slots) == 0)
		return KNOWLEDGEBASE_ERROR(404, "No characters with name [name] for [ckey].")

	if(length(slots) < index)
		return KNOWLEDGEBASE_ERROR(404, "No character index [name] for [ckey].")

	var/slot = slots[index]
	S.cd = "/character[slot]"

	var/static/list/character_params = list(
		"version",
		"last_saved",
		"OOC_Notes",
		"real_name",
		"name_is_always_random",
		"gender",
		"age",
		"height",
		"species",
		"language",
		"hair_red",
		"hair_blue",
		"hair_green",
		"grad_red",
		"grad_blue",
		"grad_green",
		"facial_red",
		"facial_blue",
		"facial_green",
		"skin_tone",
		"skin_red",
		"skin_blue",
		"skin_green",
		"hair_style_name",
		"grad_style_name",
		"facial_style_name",
		"eyes_red",
		"eyes_green",
		"eyes_blue",
		"underwear",
		"undershit",
		"socks",
		"backbag",
		"b_type",
		"use_skirt",
		"alternate_option",
		"job_preferences",
		"all_quirks",
		"positive_quirks",
		"negative_quirks",
		"neutral_quirks",
		"flavor_text",
		"med_record",
		"sec_record",
		"gen_record",
		"be_role",
		"ignore_question",
		"player_alt_titles",
		"organ_data",
		"ipc_head",
		"gear",
		"custom_items",
		"nanotrasen_relation",
		"home_system",
		"citizenship",
		"faction",
		"religion",
		"vox_rank",
		"uplinklocation",
	)

	var/list/output_params = list()

	for(var/param in character_params)
		S[param] >> output_params[param]

	return json_encode(output_params)

#undef KNOWLEDGEBASE_ERROR
