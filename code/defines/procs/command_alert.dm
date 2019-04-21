/proc/command_alert(text, title = "")
	var/command
	command += "<h1 class='alert'>[command_name()] Update</h1>"
	if (title && length(title) > 0)
		command += "<br><h2 class='alert'>[title]</h2>"

	command += "<br><span class='alert'>[text]</span><br>"
	command += "<br>"
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, command)
