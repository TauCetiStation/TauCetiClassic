/datum/preferences/proc/ShowOccupation(mob/user)
	var/limit = 22	//The amount of jobs allowed per column. Defaults to 19 to make it look nice.
	var/list/splitJobs = list("Chief Medical Officer")	//Allows you split the table by job. You can make different tables for each department by including their heads.
														//Defaults to CMO to make it look nice.
	if(!SSjob)
		return
	. = "<tt><center>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			. += "<u><a href='?_src_=prefs;preference=job;task=random'><font color=green>\[Get random job if preferences unavailable\]</font></a></u>"
		if(BE_ASSISTANT)
			. += "<u><a href='?_src_=prefs;preference=job;task=random'><font color=red>\[Be assistant if preference unavailable\]</font></a></u>"
		if(RETURN_TO_LOBBY)
			. += "<u><a href='?_src_=prefs;preference=job;task=random'><font color=purple>\[Return to lobby if preference unavailable\]</font></a></u>"

	. += "<br><a href='?_src_=prefs;preference=job;task=reset'>\[Reset\]</a>"

	if(config.use_ingame_minutes_restriction_for_jobs && config.add_player_age_value && (isnum(user.client.player_ingame_age) && user.client.player_ingame_age < config.add_player_age_value))
		. += "<br><span style='color: red; font-style: italic; font-size: 12px;'>If you are experienced SS13 player, you can ask admins about the possibility of skipping minutes restriction for jobs.</span>"

	. += "<table width='100%' cellpadding='1' cellspacing='0' style='margin-top:10px'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	. += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!SSjob)		return
	for(var/datum/job/job in SSjob.occupations)

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					. += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
			. += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		. += "<tr bgcolor='[job.selection_color]'>"
		. += "<td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(!job.map_check())
			. += "<del>[rank]</del></td><td><b> \[DISABLED]</b></td></tr>"
			continue
		if(jobban_isbanned(user, rank))
			. += "<del>[rank]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			if(config.use_ingame_minutes_restriction_for_jobs)
				var/available_in_minutes = job.available_in_real_minutes(user.client)
				. += "<del>[rank]</del></td><td> \[IN [(available_in_minutes)] MINUTES]</td></tr>"
			else
				var/available_in_days = job.available_in_days(user.client)
				. += "<del>[rank]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if(!job.is_species_permitted(user.client.prefs.species))
			. += "<del>[rank]</del></td><td><b> \[SPECIES RESTRICTED]</b></td></tr>"
			continue
		if(job_preferences["Test Subject"] == JP_LOW && (rank != "Test Subject"))
			. += "<font color=orange>[rank]</font></td><td></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			. += "<b>[rank]</b>"
		else
			. += "[rank]"

		. += "</td><td width='40%'>"

		. += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;text=[rank]'>"

		if(rank == "Test Subject")//Assistant is special
			if(job_preferences["Test Subject"])
				. += " <font color=green size=2>Yes</font>"
			else
				. += " <font color=red size=2>No</font>"
			. += "</a></td></tr>"
			if(job.alt_titles)
				. += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
			continue

		if(job_preferences[job.title] == JP_HIGH)
			. += " <font color=blue size=2>High</font>"
		else if(job_preferences[job.title] == JP_MEDIUM)
			. += " <font color=green size=2>Medium</font>"
		else if(job_preferences[job.title] == JP_LOW)
			. += " <font color=orange size=2>Low</font>"
		else
			. += " <font color=red size=2>NEVER</font>"
		if(job.alt_titles)
			. += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
		. += "</a></td></tr>"

	. += "</td></tr></table>"

	. += "</center></table>"

	. += "</tt>"

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
				UpdateJobPreference(user, href_list["text"])

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

/datum/preferences/proc/UpdateJobPreference(mob/user, role)
	var/datum/job/job = SSjob.GetJob(role)
	if(!job)
		return

	var/jpval = JP_LOW
	switch(job_preferences[job.title])
		if(JP_LOW)
			jpval = JP_MEDIUM
		if(JP_MEDIUM)
			jpval = JP_HIGH
		if(JP_HIGH)
			jpval = null

	if(role == "Test Subject")
		if(job_preferences["Test Subject"] == JP_LOW)
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
