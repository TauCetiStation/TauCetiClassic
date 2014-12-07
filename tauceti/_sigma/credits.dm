proc/credits()
	var/output = "<HEAD><TITLE>Credits</TITLE></HEAD><BODY bgcolor='#00062B' text='#DFE5EB'><div align='center'>\n"
	output += "<h2>Cast</h2>"
	output += "<h4>With the roleplay talents of:</h4>"

	for (var/mob/user in mob_list)

		if(!user.mind)
			continue

		if(user.mind.key && user.mind.name && user.mind.assigned_role)
			output += "[user.mind.key] as [user.mind.name] the [user.mind.assigned_role] [(user.mind.special_role)?"antagonist ":""]<br>"

	output += "</div></BODY>"

	for(var/client in clients)
		client << browse(output, "window=endcredits;size=400x800")