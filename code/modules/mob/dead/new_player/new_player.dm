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

	if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
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
	src << browse(entity_ja(output),"window=playersetup;size=210x240;can_close=0")
	return

/mob/dead/new_player/Stat()
	..()

	if(statpanel("Lobby"))
		stat("Game Mode:", (ticker.hide_mode) ? "Secret" : "[master_mode]")

		if(ticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", (ticker.timeLeft >= 0) ? "[round(ticker.timeLeft / 10)]s" : "DELAYED")

			stat("Players:", "[ticker.totalPlayers]")
			if(client.holder)
				stat("Players Ready:", "[ticker.totalPlayersReady]")

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
		if(ready && ticker.timeLeft <= 50)
			to_chat(src, "<span class='warning'>Locked! The round is about to start.</span>")
			return 0
		if(ticker && ticker.current_state <= GAME_STATE_PREGAME)
			ready = !ready

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") // closes the player setup window
		new_player_panel_proc()

	if(href_list["observe"])
		if(!(ckey in admin_datums) && jobban_isbanned(src, "Observer"))
			to_chat(src, "<span class='red'>You have been banned from observing. Declare yourself.</span>")
			return 0
		if(alert(src,"Are you sure you wish to observe? You will have to wait 30 minutes before being able to respawn!","Player Setup","Yes","No") == "Yes")
			if(!client)
				return 1
			var/mob/dead/observer/observer = new()

			spawning = 1
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo


			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			to_chat(src, "\blue Now teleporting.")
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
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "\red The round is either not ready, or has already finished...")
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
			to_chat(usr, "\blue There is an administrative lock on entering the game!")
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
	if(!job.is_species_permitted(client))
		return FALSE
	return TRUE


/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	if (src != usr)
		return 0
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "\red The round is either not ready, or has already finished...")
		return 0
	if(!enter_allowed)
		to_chat(usr, "\blue There is an administrative lock on entering the game!")
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

		character = character.AIize(move=0) // AIize the character, but don't move them yet

		// IsJobAvailable for AI checks that there is an empty core available in this list
		var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
		empty_playable_ai_cores -= C

		character.loc = C.loc

		//AnnounceCyborg(character, rank, "has been downloaded to the empty core in \the [character.loc.loc]")
		ticker.mode.latespawn(character)

		qdel(C)
		qdel(src)
		return

	character.loc = pick(latejoin)
	character.lastarea = get_area(loc)
	// Moving wheelchair if they have one
	if(character.buckled && istype(character.buckled, /obj/structure/stool/bed/chair/wheelchair))
		character.buckled.loc = character.loc
		character.buckled.dir = character.dir

	ticker.mode.latespawn(character)

	//ticker.mode.latespawn(character)

	if(character.mind.assigned_role != "Cyborg")
		data_core.manifest_inject(character)
		ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	//	AnnounceArrival(character, rank)

	else
		character.Robotize()

	joined_player_list += character.ckey

	qdel(src)

/mob/dead/new_player/proc/AnnounceArrival(mob/living/carbon/human/character, rank)
	if (ticker.current_state == GAME_STATE_PLAYING)
		var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)// BS12 EDIT Arrivals Announcement Computer, rather than the AI.
		if(character.mind.role_alt_title)
			rank = character.mind.role_alt_title
		a.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] has arrived on the station.", "Arrivals Announcement Computer")
		qdel(a)

/mob/dead/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = "<html><body><center>"
	dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

	if(SSshuttle) //In case Nanotrasen decides reposess CentComm's shuttles.
		if(SSshuttle.direction == 2) //Shuttle is going to centcomm, not recalled
			dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
		if(SSshuttle.direction == 1 && SSshuttle.timeleft() < 300 && SSshuttle.alert == 0) // Emergency shuttle is past the point of no recall
			dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"
		if(SSshuttle.direction == 1 && SSshuttle.alert == 1) // Crew transfer initiated
			dat += "<font color='red'>The station is currently undergoing crew transfer procedures.</font><br>"

	dat += "Choose from the following open positions:<br>"
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			var/active = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 * 60 * 10)
				active++
			dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [active])</a><br>"

	dat += "</center>"
	src << browse(entity_ja(dat), "window=latechoices;size=300x640;can_close=1")


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

	if(ticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_name = random_name(new_character.gender)
		client.prefs.randomize_appearance_for(new_character)
	else
		client.prefs.copy_to(new_character)

	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

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

/*	if(client.prefs.disabilities)
		// Set defer to 1 if you add more crap here so it only recalculates struc_enzymes once. - N3X
		new_character.dna.SetSEState(GLASSESBLOCK,1,0)
		new_character.disabilities |= NEARSIGHTED */

	if(client.prefs.disabilities & DISABILITY_NEARSIGHTED)
		new_character.dna.SetSEState(GLASSESBLOCK,1,1)
		new_character.disabilities |= NEARSIGHTED

	if(client.prefs.disabilities & DISABILITY_EPILEPTIC)
		new_character.dna.SetSEState(EPILEPSYBLOCK,1,1)
		new_character.disabilities |= EPILEPSY

	if(client.prefs.disabilities & DISABILITY_COUGHING)
		new_character.dna.SetSEState(COUGHBLOCK,1,1)
		new_character.disabilities |= COUGHING

	if(client.prefs.disabilities & DISABILITY_TOURETTES)
		new_character.dna.SetSEState(TWITCHBLOCK,1,1)
		new_character.disabilities |= TOURETTES

	if(client.prefs.disabilities & DISABILITY_NERVOUS)
		new_character.dna.SetSEState(NERVOUSBLOCK,1,1)
		new_character.disabilities |= NERVOUS

	// And uncomment this, too.
	new_character.dna.UpdateSE()
	if(key)
		new_character.key = key		//Manually transfer the key to log them in

	return new_character

/mob/dead/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Show Crew Manifest</h4>"
	dat += data_core.get_manifest(OOC = 1)

	src << browse(entity_ja(dat), "window=manifest;size=370x420;can_close=1")

/mob/dead/new_player/Move()
	return 0

/mob/dead/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window

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

/mob/dead/new_player/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, mob/speaker = null, hard_to_hear = 0)
	return
