var/global/list/datum/bridge_command/bridge_commands

/world/proc/send2bridge(msg, list/type = list(BRIDGE_SERVICE), attachment_msg, attachment_title, attachment_color, attachment_footer, mention)

	if(!config.chat_bridge || !islist(type) || !type.len || !(msg || attachment_msg || attachment_title))
		return 0

	var/list/json = list()

	json["type"] = type

	if(msg)
		json["message"] = msg

	if(attachment_msg)
		json["attachment_msg"] = attachment_msg

	if(attachment_title)
		json["attachment_title"] = attachment_title

	if(attachment_color)
		json["attachment_color"] = attachment_color

	if(attachment_footer)
		json["attachment_footer"] = attachment_footer

	if(mention)
		json["mention"] = mention

	var/encoded_json = replacetext(json_encode(json), "'", @"\\`")
	//world.log << "send2bridge json: [encoded_json]"

	spawn()
		var/ext = world.ext_python("get.py", "[shelleo_url_scrub(config.chat_bridge)] --json='[encoded_json]'")

		if(!ext) // ext_python error
			return

		var/list/result = json_decode(ext)
		if(result["success"] != 1)
			if(result["error"])
				ERROR("Unsuccessful send2bridge, json:\n \t[encoded_json]\n \tbridge error:\n \t[result["error"]]")
			else
				ERROR("Unsuccessful send2bridge, json:\n \t[encoded_json]")

	return 1

// Topic format: bridge&bridge_secret=secret&bridge_type=type&bridge_from_user=username&bridge_from_uid=DiscordID&bridge_from_suffix=Discord&bridge_arg_1=...
/world/proc/bridge2game(list/packet_data)
	if(!config.chat_bridge)
		return

	if(global.bridge_secret == null || !istext(packet_data["bridge_secret"]) || global.bridge_secret != packet_data["bridge_secret"])
		return

	packet_data["bridge_secret"] = "SECRET"
	log_href("WTOPIC: BRIDGE: \"[list2params(packet_data)]\"")

	packet_data["bridge_from_user"] = ckey(packet_data["bridge_from_user"])
	packet_data["bridge_from_suffix"] = ckey(packet_data["bridge_from_suffix"])
	packet_data["bridge_from_uid"] = sanitize_numbers(packet_data["bridge_from_uid"])

	if(!packet_data["bridge_from_user"] || !packet_data["bridge_from_uid"] || !packet_data["bridge_from_suffix"])
		return

	var/datum/bridge_command/command = bridge_commands[packet_data["bridge_type"]]
	if(command)
		command.execute(packet_data)

/datum/bridge_command
	var/name
	var/desc
	var/format
	var/example

	var/position = 100 // for sorting purpose

/datum/bridge_command/proc/execute(list/params)
	return
