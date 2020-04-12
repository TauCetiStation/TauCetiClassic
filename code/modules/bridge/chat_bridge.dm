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

	var/encoded_json = replacetext(json_encode(json), "'", @"\\`")//todo: replace on json_encode() after unicode update
	//world.log << "send2bridge json: [encoded_json]"

	spawn()
		var/list/result = json_decode(world.ext_python("get.py", "[shelleo_url_scrub(config.chat_bridge)] --json='[encoded_json]'"))
		if(result["success"] != 1)
			if(result["error"])
				ERROR("Unsuccessful send2bridge, json:\n \t[encoded_json]\n \tbridge error:\n \t[result["error"]]")
			else
				ERROR("Unsuccessful send2bridge, json:\n \t[encoded_json]")
