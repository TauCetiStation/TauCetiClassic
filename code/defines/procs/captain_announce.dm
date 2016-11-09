/proc/captain_announce(message, title = "Priority Announcement", announcer = "")
	to_chat(world, "<h1 class='alert'>[html_encode(title)]</h1>")
	to_chat(world, "<span class='alert'>[sanitize(message)]</span>")
	if(announcer)
		to_chat(world, "<span class='alert'> -[html_encode(announcer)]</span>")
	to_chat(world, "<br>")
