/datum/bridge_command/who
	name = "who"
	desc = "Get player list"
	format = "@Bot who"
	example = "@Bot who"
	position = 3

/datum/bridge_command/who/execute(list/params)
	var/message
	var/footer

	var/crew = ""
	var/observers = ""

	for(var/client/C in clients)
		var/entry = "**[C.key]**"

		if(isobserver(C.mob))
			var/mob/dead/observer/O = C.mob
			if(O.started_as_observer)
				entry += " (O)"
			else
				entry += " as [C.mob.real_name] (D)"

			observers += "[entry]\n"
			continue

		
		entry += " as [C.mob.real_name]"
		
		if(C.mob.mind && C.mob.mind.assigned_job)
			entry += " ([C.mob.mind.assigned_job.title])"

		switch(C.mob.stat)
			if(UNCONSCIOUS)
				entry += " (U)"
			if(DEAD)
				entry += " (D)"

		if(isanyantag(C.mob))
			entry += " **(A)**"

		crew += "[entry]\n"

	if(!length(crew) && !length(observers))
		message = "No players online"
	else
		message = "**CREW**:\n[crew]**OBSERVERS**:\n[observers]"
		footer = "Abbreviations: (O)bserver, (D)ead, (U)nconscious, (A)ntagonist\nJobs is shown at the time of spawn and may differ from the actual"

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: who",
		attachment_msg = "Players list requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_footer = footer,
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
