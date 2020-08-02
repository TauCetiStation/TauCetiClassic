/mob/dead/new_player
	universal_speak = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	stat = DEAD
	canmove = FALSE
	anchored = TRUE // don't get pushed around

	var/ready             = FALSE
	var/spawning          = FALSE // Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers      = FALSE // Player counts for the Lobby tab
	var/totalPlayersReady = FALSE

/mob/dead/new_player/atom_init()
	if(length(newplayer_start))
		loc = pick(newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = loc
	. = ..()
	new_player_list += src

/mob/dead/new_player/Destroy()
	new_player_list -= src
	return ..()

/mob/dead/new_player/say(msg)
	if(client)
		client.ooc(msg)

/mob/dead/new_player/verb/new_player_panel()
	set src = usr
	new_player_panel_proc()

/mob/dead/new_player/proc/new_player_panel_proc()
	var/output = null
	if(length(src.key) > 15)
		output += "<div align='center'><B>Welcome,<br></B>"
		output += "<div align='center'><B>[src.key]!</B>"
	else
		output += "<div align='center'><B>Welcome, [src.key]!</B>"
	output +="<hr>"
	output += "<p><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A></p>"

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		if(!ready)	output += "<p><a href='byond://?src=\ref[src];ready=1'>Declare Ready</A></p>"
		else	output += "<p><b>You are ready</b> (<a href='byond://?src=\ref[src];ready=2'>Cancel</A>)</p>"

	else
		output += "<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"

	output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"

/*	if(!IsGuestKey(src.key))
		establish_db_connection()

		if(dbcon.IsConnected())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM erro_poll_textreply WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break

			if(newpoll)
				output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"
commented cause polls are kinda broken now, needs refactoring */

	output += "</div>"
	src << browse(output,"window=playersetup;size=210x240;can_close=0")
	return

/mob/dead/new_player/Stat()
	..()

	if(statpanel("Lobby"))
		stat("Game Mode:", (SSticker.hide_mode) ? "Secret" : "[master_mode]")

		if(world.is_round_preparing())
			stat("Time To Start:", (SSticker.timeLeft >= 0) ? "[round(SSticker.timeLeft / 10)]s" : "DELAYED")

			stat("Players:", "[SSticker.totalPlayers]")
			if(client.holder)
				stat("Players Ready:", "[SSticker.totalPlayersReady]")

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return 0

	if(!client)
		return 0

	if(href_list["show_preferences"])
		client << browse_rsc('html/prefs/dossier_empty.png')
		client << browse_rsc('html/prefs/opacity7.png')
		client.prefs.ShowChoices(src)
		return 1

	if(href_list["ready"])
		if(ready && SSticker.timeLeft <= 50)
			to_chat(src, "<span class='warning'>Locked! The round is about to start.</span>")
			return 0
		if(SSticker && SSticker.current_state <= GAME_STATE_PREGAME)
			ready = !ready

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") // closes the player setup window
		new_player_panel_proc()

	if(href_list["observe"])
		if(!(ckey in admin_datums) && jobban_isbanned(src, "Observer"))
			to_chat(src, "<span class='red'>You have been banned from observing. Declare yourself.</span>")
			return 0
		if(!SSmapping.station_loaded)
			to_chat(src, "<span class='red'>There is no station yet, please wait.</span>")
			return 0
		if(alert(src,"Are you sure you wish to observe? You will have to wait 30 minutes before being able to respawn!","Player Setup","Yes","No") == "Yes")
			if(!client)
				return 1
			var/mob/dead/observer/observer = new()

			spawning = 1
			playsound_stop(CHANNEL_MUSIC) // MAD JAMS cant last forever yo


			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			to_chat(src, "<span class='notice'>Now teleporting.</span>")
			observer.loc = O.loc
			observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.

			// client.prefs.update_preview_icon()
			// observer.icon = client.prefs.preview_icon
			observer.icon = 'icons/mob/mob.dmi'
			observer.icon_state = "ghost"
			observer.alpha = 127

			if(client.prefs.be_random_name)
				client.prefs.real_name = random_name(client.prefs.gender)
			observer.real_name = client.prefs.real_name
			observer.name = observer.real_name
			if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
				observer.verbs -= /mob/dead/observer/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
			observer.key = key
			qdel(src)

			return 1

	if(href_list["late_join"])
		if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return

		if(client.prefs.species != HUMAN)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return FALSE

		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return

		if(client.prefs.species != HUMAN)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return FALSE
		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(href_list["preference"] && (!ready || (href_list["preference"] == "close")))
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

/*	if(href_list["privacy_poll"])
		establish_db_connection()
		if(!dbcon.IsConnected())
			return
		var/voted = 0

		// First check if the person has not voted yet.
		var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_privacy WHERE ckey='[src.ckey]'")
		query.Execute()
		while(query.NextRow())
			voted = 1
			break

		// This is a safety switch, so only valid options pass through
		var/option = "UNKNOWN"
		switch(href_list["privacy_poll"])
			if("signed")
				option = "SIGNED"
			if("anonymous")
				option = "ANONYMOUS"
			if("nostats")
				option = "NOSTATS"
			if("later")
				usr << browse(null,"window=privacypoll")
				return
			if("abstain")
				option = "ABSTAIN"

		if(option == "UNKNOWN")
			return

		if(!voted)
			var/sql = "INSERT INTO erro_privacy VALUES (null, Now(), '[src.ckey]', '[option]')"
			var/DBQuery/query_insert = dbcon.NewQuery(sql)
			query_insert.Execute()
			to_chat(usr, "<b>Thank you for your vote!</b>")
			usr << browse(null,"window=privacypoll")


	if(href_list["showpoll"])

		handle_player_polling()
		return

	if(href_list["pollid"])

		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid))
			src.poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		switch(votetype)
			if("OPTION")
				var/optionid = text2num(href_list["voteoptionid"])
				vote_on_poll(pollid, optionid)
			if("TEXT")
				var/replytext = href_list["replytext"]
				log_text_poll_reply(pollid, replytext)
			if("NUMVAL")
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating))
								return

						vote_on_numval_poll(pollid, optionid, rating)
			if("MULTICHOICE")
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						vote_on_poll(pollid, optionid, 1)
*/ // commented cause polls are kinda broken now, needs refactoring

/mob/dead/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return FALSE
	if(!job.is_position_available())
		return FALSE
	if(jobban_isbanned(src, rank))
		return FALSE
	if(!job.player_old_enough(client))
		return FALSE
	if(!job.is_species_permitted(client.prefs.species))
		return FALSE
	if(!job.map_check())
		return FALSE
	return TRUE


/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	if (src != usr)
		return 0
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
		return 0
	if(!enter_allowed)
		to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
		return 0
	if(!IsJobAvailable(rank))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return 0

	spawning = 1
	close_spawn_windows()

	SSjob.AssignRole(src, rank, 1)

	var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
	SSjob.EquipRank(character, rank, 1)					//equips the human

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(character.mind.assigned_role == "AI")

		// IsJobAvailable for AI checks that there is an empty core available in this list
		var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
		empty_playable_ai_cores -= C

		character.loc = C.loc

		character = character.AIize(move=0) // AIize the character, but don't move them yet

		//AnnounceCyborg(character, rank, "has been downloaded to the empty core in \the [character.loc.loc]")
		SSticker.mode.latespawn(character)

		qdel(C)
		qdel(src)
		return

	character.loc = pick(latejoin)
	character.lastarea = get_area(loc)
	// Moving wheelchair if they have one
	if(character.buckled && istype(character.buckled, /obj/structure/stool/bed/chair/wheelchair))
		character.buckled.loc = character.loc
		character.buckled.dir = character.dir

	SSticker.mode.latespawn(character)

	//SSticker.mode.latespawn(character)

	if(character.mind.assigned_role != "Cyborg")
		data_core.manifest_inject(character)
		SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	//	AnnounceArrival(character, rank)

	else
		character.Robotize()

	joined_player_list += character.ckey

	if(!issilicon(character))
		SSquirks.AssignQuirks(character, character.client, TRUE)

	if(character.client)
		character.client.guard.time_velocity_spawn = world.timeofday

	qdel(src)

/mob/dead/new_player/proc/AnnounceArrival(mob/living/carbon/human/character, rank)
	if (SSticker.current_state == GAME_STATE_PLAYING)
		var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)// BS12 EDIT Arrivals Announcement Computer, rather than the AI.
		if(character.mind.role_alt_title)
			rank = character.mind.role_alt_title
		a.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] has arrived on the station.", "Arrivals Announcement Computer")
		qdel(a)

/mob/dead/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	var/mins = round((mills % 36000) / 600)
	var/hours = round(mills / 36000)
	var/which_time_is_it = ""
	if(mins == 1)
		which_time_is_it = "<b>[mins]</b> minute."
	else
		which_time_is_it = "<b>[mins]</b> minutes."
	if(hours)
		if(hours == 1)
			which_time_is_it = "<b>[hours]</b> hour and [which_time_is_it]"
		else
			which_time_is_it = "<b>[hours]</b> hours and [which_time_is_it]"

	var/dat = "<div class='notice'>Round Duration: [which_time_is_it]</div>"

	if(SSshuttle) // In case Nanotrasen decides reposess CentComm's shuttles.
		switch(SSshuttle.direction)
			if(2) // Shuttle is going to centcomm, not recalled
				dat += "<div class='notice red'>The station has been evacuated.</div><br>"
			if(1)
				if(SSshuttle.timeleft() < 300 && SSshuttle.alert == 0) // Emergency shuttle is past the point of no recall
					dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"
				else if(SSshuttle.alert == 1) // Crew transfer initiated
					dat += "<div class='notice red'>The station is currently undergoing crew transfer procedures.</div><br>"
	var/available_job_count = 0
	var/number_of_extra_line_breaks = 0 // We will need it in the end.
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			available_job_count++

	if(!available_job_count)
		dat += "<div class='notice red'>There are currently no open positions!</div>"
	else
		dat += "<div class='clearBoth'>Choose from the following open positions:</div>"
		var/list/categorizedJobs = list(
			"Command" = list(jobs = list(), titles = command_positions, color = "#aac1ee"),
			"Engineering" = list(jobs = list(), titles = engineering_positions, color = "#ffd699"),
			"Security" = list(jobs = list(), titles = security_positions, color = "#ff9999"),
			"Miscellaneous" = list(jobs = list(), titles = list(), color = "#ffffff", colBreak = TRUE),
			"Synthetic" = list(jobs = list(), titles = nonhuman_positions, color = "#ccffcc"),
			"Service" = list(jobs = list(), titles = civilian_positions, color = "#cccccc"),
			"Medical" = list(jobs = list(), titles = medical_positions, color = "#99ffe6", colBreak = TRUE),
			"Science" = list(jobs = list(), titles = science_positions, color = "#e6b3e6"),
		)

		for(var/datum/job/job in SSjob.occupations)
			if(job && IsJobAvailable(job.title))
				var/categorized = FALSE
				for(var/jobcat in categorizedJobs)
					var/list/jobs = categorizedJobs[jobcat]["jobs"]
					if(job.title in categorizedJobs[jobcat]["titles"])
						categorized = TRUE
						if(jobcat == "Command")

							if(job.title == "Captain") // Put captain at top of command jobs
								jobs.Insert(1, job)
							else
								jobs += job
						else // Put heads at top of non-command jobs
							if(job.title in command_positions)
								jobs.Insert(1, job)
							else
								jobs += job
				if(!categorized)
					categorizedJobs["Miscellaneous"]["jobs"] += job


		dat += "<table><tr><td valign='top'>"
		for(var/jobcat in categorizedJobs)
			if(categorizedJobs[jobcat]["colBreak"])
				dat += "</td><td valign='top'>"
			if(!length(categorizedJobs[jobcat]["jobs"]))
				continue
			var/color = categorizedJobs[jobcat]["color"]
			dat += "<fieldset style='border: 2px solid [color]; display: inline'>"
			dat += "<legend align='center' style='color: [color]'>[jobcat]</legend>"
			for(var/datum/job/job in categorizedJobs[jobcat]["jobs"])
				var/position_class = "otherPosition"
				if(job.title in command_positions)
					position_class = "commandPosition"
				var/active = 0
				if(job.current_positions) // If theres any people on this job already, we check if they are active and display it
					for(var/mob/M in player_list) // Only players with the job assigned and AFK for less than 10 minutes count as active
						if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 * 60 * 10)
							active++
				if(job.current_positions && active < job.current_positions)
					dat += "<a class='[position_class]' style='display:block;width:170px' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])<br><i>(Active: [active])</i></a>"
					number_of_extra_line_breaks++
				else
					dat += "<a class='[position_class]' style='display:block;width:170px' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a>"
				categorizedJobs[jobcat]["jobs"] -= job

			dat += "</fieldset><br>"
		dat += "</td></tr></table>"
		dat += "</div></div>"

	// Removing the old window method but leaving it here for reference
	//src << browse(dat, "window=latechoices;size=300x640;can_close=1")

	// Added the new browser window method
	var/accurate_length = 600
	if(number_of_extra_line_breaks) // We will expand window length for each <br>(Active: [active]) until its reaches 700 (worst cases)
		accurate_length = min(700, accurate_length + (number_of_extra_line_breaks * 8))
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 680, accurate_length)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(dat)
	popup.open(FALSE) // FALSE is passed to open so that it doesn't use the onclose() proc


/mob/dead/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/new_character

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(chosen_species)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		if(is_species_whitelisted(chosen_species) || has_admin_rights())
			new_character = new(loc, client.prefs.species)

	if(!new_character)
		new_character = new(loc)

	new_character.lastarea = get_area(loc)
	if(client.prefs.language)
		new_character.add_language(client.prefs.language)

	if(SSticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_name = random_name(new_character.gender)
		client.prefs.randomize_appearance_for(new_character)
	else
		client.prefs.copy_to(new_character)

	playsound_stop(CHANNEL_MUSIC) // MAD JAMS cant last forever yo

	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		if(mind.assigned_role == "Clown")				//give them a clownname if they are a clown
			new_character.real_name = pick(clown_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
			new_character.rename_self("clown")
		mind.original = new_character
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	new_character.name = real_name
	new_character.dna.ready_dna(new_character)
	new_character.dna.b_type = client.prefs.b_type
	new_character.dna.UpdateSE()

	if(key)
		new_character.key = key		//Manually transfer the key to log them in

	return new_character

/mob/dead/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Show Crew Manifest</h4>"
	dat += data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/dead/new_player/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	return FALSE

/mob/dead/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences_window")
	if(client)
		client.clear_character_previews()

/mob/dead/new_player/proc/has_admin_rights()
	return (client && client.holder && (client.holder.rights & R_ADMIN))

/mob/dead/new_player/proc/is_species_whitelisted(datum/species/S)
	if(!S)
		return 1
	return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !S.flags[IS_WHITELISTED]

/mob/dead/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species)
		return HUMAN

	if(is_species_whitelisted(chosen_species) || has_admin_rights())
		return chosen_species.name

	return HUMAN

/mob/dead/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/dead/new_player/is_ready()
	return ready && ..()

/mob/dead/new_player/hear_say(message, verb = "says", datum/language/language = null, alt_name = "",italics = 0, mob/speaker = null)
	return

/mob/dead/new_player/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0, vname ="")
	return
