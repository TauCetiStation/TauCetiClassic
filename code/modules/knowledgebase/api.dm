var/global/knowledgebase_secret = "test"

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
// * index - is an integer used only if the player has multiple characters with the same name to specify which of the characters to output.
/world/proc/process_knowledgebase_request(list/packed_data)
	if(!config.knowledgebase)
		return "error=410"

	if(global.knowledgebase_secret == null)
		return "error=410"
	if(!istext(packed_data["secret"]))
		return "error=403&message=Incorrect secret."
	if(global.knowledgebase_secret != packed_data["secret"])
		return "error=403&message=Incorrect secret."

	packed_data["secret"] = "SECRET"
	log_href("WTOPIC: KNOWLEDGEBASE: \"[list2params(packed_data)]\"")

	packed_data["userid"] = ckey(packed_data["userid"])
	packed_data["ckey"] = ckey(packed_data["ckey"])
	packed_data["name"] = ckey(packed_data["name"])
	packed_data["index"] = sanitize_integer(text2num(packed_data["index"]), min=1, max=MAX_SAVE_SLOTS_SUPPORTER)

	if(!packed_data["userid"] || !packed_data["ckey"] || !packed_data["name"])
		return

	var/ckey = packed_data["ckey"]

	var/path = "data/player_saves/[ckey[1]]/[ckey]/preferences.sav"

	if(!fexists(path))
		return "error=404&message=No preferences.sav for [ckey]."

	var/savefile/S = new /savefile(path)
	if(!S)
		return "error=500&message=Savefile could not be loaded."

	var/list/slots = character_name2slots(S, packed_data["name"])
	if(length(slots) == 0)
		return "error=404&message=No characters with name [packed_data["name"]] for [ckey]."

	if(length(slots) < packed_data["index"])
		return "error=404&message=No character index [packed_data["index"]] for [ckey]."

	var/slot = slots[packed_data["index"]]

	S.cd = "/character[slot]"

	var/character_age
	S["age"] >> character_age

	return json_encode(list(
		"name" = packed_data["name"],
		"age" = character_age,
	))
