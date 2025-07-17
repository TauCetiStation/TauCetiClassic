/datum/preferences/proc/ShowOccupation(mob/user)
	if(!SSjob)
		return
	. = "<tt><center>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			. += "<u><a href='byond://?_src_=prefs;preference=job;task=random'><font color=green>\[Get random job if preferences unavailable\]</font></a></u>"
		if(BE_ASSISTANT)
			. += "<u><a href='byond://?_src_=prefs;preference=job;task=random'><font color=red>\[Be assistant if preference unavailable\]</font></a></u>"
		if(RETURN_TO_LOBBY)
			. += "<u><a href='byond://?_src_=prefs;preference=job;task=random'><font color=purple>\[Return to lobby if preference unavailable\]</font></a></u>"

	. += "<br><a href='byond://?_src_=prefs;preference=job;task=reset'>\[Reset\]</a>"

	if(config.use_ingame_minutes_restriction_for_jobs && config.add_player_age_value && (isnum(user.client.player_ingame_age) && user.client.player_ingame_age < config.add_player_age_value))
		. += "<br><span style='color: red; font-style: italic; font-size: 12px;'>If you are experienced SS13 player, you can ask admins about the possibility of skipping minutes restriction for jobs.</span>"

	. += "<table width='100%' cellpadding='1' cellspacing='0' style='margin-top:10px'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	. += "<div width='100%' style='column-count: 2'>"

	if (!SSjob.initialized)
		return
	//for(var/datum/job/job as anything in SSjob.all_occupations)
	for(var/department_tag in SSjob.departments_occupations)
		. += "<div style='break-inside: avoid;'>"
		for(var/job_tag in SSjob.departments_occupations[department_tag])
			var/datum/job/job = SSjob.name_occupations[job_tag]
			if((department_tag == DEP_COMMAND) && length(job.departments) > 1)
				// show heads in related department, except if it's captain
				continue

			. += "<div width='50%' style='background-color: [job.selection_color]; padding: 2px 0; display: flow-root;'>"
			var/rank = job.title
			if(!job.map_check())
				. += "<del>[rank]</del><b> \[DISABLED]</b></div>"
				continue
			if(jobban_isbanned(user, rank))
				. += "<del>[rank]</del><b><a href='byond://?_src_=prefs;preference=open_jobban_info;position=[rank]'> \[BANNED]</a></b></div>"
				continue
			if(!job.player_old_enough(user.client))
				if(config.use_ingame_minutes_restriction_for_jobs)
					var/available_in_minutes = job.available_in_real_minutes(user.client)
					. += "<del>[rank]</del> \[IN [(available_in_minutes)] MINUTES]</div>"
				else
					var/available_in_days = job.available_in_days(user.client)
					. += "<del>[rank]</del> \[IN [(available_in_days)] DAYS]</div>"
				continue
			if(!job.is_species_permitted(user.client.prefs.species))
				. += "<del>[rank]</del><b> \[SPECIES RESTRICTED]</b></div>"
				continue
			if(job_preferences["Assistant"] == JP_LOW && (rank != "Assistant"))
				. += "<font color=orange>[rank]</font></div>"
				continue
			if((rank in SSjob.heads_positions) || (rank == JOB_AI))//Bold head jobs
				. += "<b>[rank]</b>"
			else
				. += "[rank]"

			if(job.alt_titles)
				. += " (<a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a>)"

			. += "<a class='white' style='display: inline-block; float: right;' href='byond://?_src_=prefs;preference=job;task=setJobLevel;dir=higher;text=[rank]' oncontextmenu='window.location.href=\"byond://?_src_=prefs;preference=job;task=setJobLevel;text=[rank]\";return false;'>"

			if(rank =="Assistant")//Assistant is special
				if(job_preferences["Assistant"])
					. += "<font color=green size=2>Yes</font>"
				else
					. += "<font color=red size=2>No</font>"
				. += "</a>"
				. += "</div>"
				continue

			if(job_preferences[job.title] == JP_HIGH)
				. += "<font color=blue size=2>High</font>"
			else if(job_preferences[job.title] == JP_MEDIUM)
				. += "<font color=green size=2>Medium</font>"
			else if(job_preferences[job.title] == JP_LOW)
				. += "<font color=orange size=2>Low</font>"
			else
				. += "<font color=red size=2>NEVER</font>"
			. += "</a>"
			. += "</div>"
		
		. += "</div>"

	. += "</div></table>"

	. += "</center></tt>"

/datum/preferences/proc/process_link_occupation(mob/user, list/href_list)
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("reset")
				ResetJobs()
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
			if ("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if (job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], href_list["dir"])

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/UpdateJobPreference(mob/user, role, dir)
	var/datum/job/job = SSjob.GetJob(role)
	if(!job)
		return

	var/jpval = null //LMB
	var/jpval2 = null //RMB
	switch(job_preferences[job.title])
		if(null)
			jpval = JP_LOW
			jpval2 = JP_HIGH
		if(JP_LOW)
			jpval = JP_MEDIUM
			jpval2 = null
		if(JP_MEDIUM)
			jpval = JP_HIGH
			jpval2 = JP_LOW
		if(JP_HIGH)
			jpval = null
			jpval2 = JP_MEDIUM
	if(!dir) //RMB case
		jpval = jpval2

	if(role == "Assistant")
		if(job_preferences["Assistant"] == JP_LOW)
			jpval = null
		else
			jpval = JP_LOW

	SetJobPreferenceLevel(job, jpval)
	return TRUE

/datum/preferences/proc/ResetJobs()
	job_preferences = list()

/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if(!job)
		return FALSE

	if(level == JP_HIGH)
		// Set all other high to medium
		for(var/j in job_preferences)
			if(job_preferences[j] == JP_HIGH)
				job_preferences[j] = JP_MEDIUM

	if(level)
		job_preferences[job.title] = level
	else
		job_preferences -= job.title
	return TRUE
