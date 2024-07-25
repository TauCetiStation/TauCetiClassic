/mob/dead/new_player
	universal_speak = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	stat = DEAD
	canmove = FALSE
	anchored = TRUE // don't get pushed around
	hud_possible = list()

	var/ready             = FALSE
	var/spawning          = FALSE // Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers      = FALSE // Player counts for the Lobby tab
	var/totalPlayersReady = FALSE
	var/client/my_client

/mob/dead/new_player/atom_init()
	if(length(newplayer_start))
		loc = pick(newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = loc
	. = ..()
	new_player_list += src

/mob/dead/new_player/Destroy()
	if(my_client)
		hide_titlescreen()
		my_client = null

	new_player_list -= src
	return ..()

/mob/dead/new_player/say(msg)
	if(client)
		client.ooc(msg)

/mob/dead/new_player/proc/show_titlescreen()
	winset(client, "lobbybrowser", "is-disabled=false;is-visible=true")

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/lobby)
	assets.send(src)

	if(global.custom_lobby_image)
		client << browse(global.custom_lobby_image, "file=titlescreen.gif;display=0") // png? jpg?
	else
		if(client.prefs.lobbyanimation)
			client << browse(global.lobby_screens[global.lobby_screen]["mp4"], "file=[global.lobby_screen].mp4;display=0")
		client << browse(global.lobby_screens[global.lobby_screen]["png"], "file=[global.lobby_screen].png;display=0")

	client << browse(get_lobby_html(), "window=lobbybrowser")

/mob/dead/new_player/proc/hide_titlescreen()
	if(my_client.mob) // Check if the client is still connected to something
		// Hide title screen, allowing player to see the map
		winset(my_client, "lobbybrowser", "is-disabled=true;is-visible=false")

/mob/dead/new_player/prepare_huds()
	return

/mob/dead/new_player/Stat()
	..()

	if(statpanel("Lobby"))
		stat("Game Mode:", SSticker.bundle ? "[SSticker.bundle.name]" : "[master_mode]")

		if(world.is_round_preparing())
			stat("Time To Start:", (SSticker.timeLeft >= 0) ? "[round(SSticker.timeLeft / 10)]s" : "DELAYED")

			stat("Players:", "[SSticker.totalPlayers]")
			if(client.holder)
				stat("Players Ready:", "[SSticker.totalPlayersReady]")

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr || !client)
		return

	if(href_list["lobby_changelog"])
		client.changes()
		return

	if(href_list["lobby_setup"])
		client << browse_rsc('html/prefs/dossier_empty.png')
		client << browse_rsc('html/prefs/opacity7.png')
		client.prefs.ShowChoices(src)
		return

	if(href_list["lobby_ready"])
		if(config.alt_lobby_menu)
			return
		if(ready && SSticker.timeLeft <= 50)
			to_chat(src, "<span class='warning'>Locked! The round is about to start.</span>")
			return
		if(SSticker && SSticker.current_state <= GAME_STATE_PREGAME)
			ready = !ready
			client << output(ready, "lobbybrowser:setReadyStatus")
		return

	if(href_list["lobby_be_special"])
		if(config.alt_lobby_menu)
			return
		if(client.prefs.selected_quality_name)
			var/datum/quality/quality = SSqualities.qualities_by_type[SSqualities.registered_clients[client.ckey]]
			to_chat(src, "<font color='green'><b>Выбор сделан.</b></font>")
			SSqualities.announce_quality(client, quality)
			return
		if(!client.prefs.selecting_quality)
			var/datum/preferences/P = client.prefs
			P.selecting_quality = TRUE
			if(tgui_alert(
				src,
				"Вы уверены, что хотите быть особенным? Вам будет выдана случайная положительная, нейтральная или отрицательная черта.",
				"Особенность",
				list("ДА!!!", "Нет")) == "ДА!!!")
				SSqualities.register_client(client)
			P.selecting_quality = FALSE
		return

	if(href_list["lobby_observe"])
		if(!(ckey in admin_datums) && jobban_isbanned(src, "Observer"))
			to_chat(src, "<span class='red'>You have been banned from observing. Declare yourself.</span>")
			return
		if(!SSmapping.station_loaded)
			to_chat(src, "<span class='red'>There is no station yet, please wait.</span>")
			return
		if(tgui_alert(src,"Are you sure you wish to observe? You will have to wait 30 minutes before being able to respawn!","Player Setup", list("Yes","No")) == "Yes")
			if(!client)
				return
			spawn_as_observer()

			return

	if(href_list["lobby_join"])
		if(config.alt_lobby_menu)
			return
		if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return

		if(client.prefs.species != HUMAN)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				tgui_alert(usr, "You are currently not whitelisted to play [client.prefs.species].")
				return FALSE

		LateChoices()
		return

	if(href_list["event_join"])
		if(!config.alt_lobby_menu)
			return
		if(!spawners_menu)
			spawners_menu = new()

		spawners_menu.tgui_interact(src)
		return

	if(href_list["lobby_crew"])
		ViewManifest()
		return

	if(href_list["SelectedJob"])
		if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game for non-observers!</span>")
			return

		if(client.prefs.species != HUMAN)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				tgui_alert(usr, "You are currently not whitelisted to play [client.prefs.species].")
				return FALSE
		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(href_list["preference"] && (!ready || (href_list["preference"] == "close")))
		if(client)
			client.prefs.process_link(src, href_list)
		return

	else
		to_chat(src, "Locked! You are ready.")
		return

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
	if(!job.map_check())
		return FALSE
	if(!job.is_species_permitted(client.prefs.species))
		var/datum/quality/quality = SSqualities.qualities_by_name[client.prefs.selected_quality_name]
		//skip check by quality
		if(istype(quality, /datum/quality/quirkieish/unrestricted))
			return TRUE
		return FALSE
	return TRUE

/mob/dead/new_player/proc/spawn_as_observer()
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

	return observer

/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	if (src != usr)
		return 0
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
		return 0
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game for non-observers!</span>")
		return 0
	if(!IsJobAvailable(rank))
		to_chat(usr, "<span class='notice'>[rank] is not available. Please try another.</span>")
		return 0

	spawning = 1
	close_spawn_windows()

	SSjob.AssignRole(src, rank, 1)

	var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind


	SSjob.EquipRank(character, rank, TRUE)					//equips the human

	if(!issilicon(character))
		SSquirks.AssignQuirks(character, character.client, TRUE)
		SSqualities.give_quality(character, TRUE)
		character.PutDisabilityMarks()

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(character.mind.assigned_role == "AI")

		// IsJobAvailable for AI checks that there is an empty core available in this list
		var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
		empty_playable_ai_cores -= C

		character.loc = C.loc

		character = character.AIize(move=0) // AIize the character, but don't move them yet

		show_location_blurb(character.client)
		//AnnounceCyborg(character, rank, "has been downloaded to the empty core in \the [character.loc.loc]")
		SSticker.mode.latespawn(character)

		qdel(C)
		qdel(src)
		return

	character.forceMove(pick(latejoin), keep_buckled = TRUE)
	show_location_blurb(character.client)

	SSticker.mode.latespawn(character)

	//SSticker.mode.latespawn(character)

	if(character.mind.assigned_role != "Cyborg")
		data_core.manifest_inject(character)
		SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	//	AnnounceArrival(character, rank)

	else
		character.Robotize()

	joined_player_list += character.ckey

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
			"NT Representatives" = list(jobs = list(), titles = centcom_positions, color = "#6c7391"),
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

	// Added the new browser window method
	var/accurate_length = 600
	if(number_of_extra_line_breaks) // We will expand window length for each <br>(Active: [active]) until its reaches 700 (worst cases)
		accurate_length = min(700, accurate_length + (number_of_extra_line_breaks * 8))
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 680, accurate_length)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(dat)
	popup.open()


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
		new_character.add_language(client.prefs.language, LANGUAGE_NATIVE)

	if(SSticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_name = random_name(new_character.gender)
		client.prefs.randomize_appearance_for(new_character)
	else
		client.prefs.copy_to(new_character)

	playsound_stop(CHANNEL_MUSIC) // MAD JAMS cant last forever yo

	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		mind.original = new_character
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	new_character.name = real_name
	new_character.dna.ready_dna(new_character)
	new_character.dna.UpdateSE()
	new_character.dna.original_character_name = new_character.real_name
	new_character.nutrition = rand(NUTRITION_LEVEL_HUNGRY, NUTRITION_LEVEL_WELL_FED)
	var/old_base_metabolism = new_character.get_metabolism_factor()
	new_character.metabolism_factor.Set(old_base_metabolism * rand(9, 11) * 0.1)

	if(key)
		new_character.key = key		//Manually transfer the key to log them in

	return new_character

/mob/dead/new_player/proc/ViewManifest()
	var/dat = data_core.html_manifest(OOC = 1)

	var/datum/browser/popup = new(src, "manifest", "Crew Manifest", 370, 420, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

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
