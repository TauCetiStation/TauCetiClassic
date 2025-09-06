/mob/dead/new_player
	universal_speak = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	stat = DEAD
	canmove = FALSE
	anchored = TRUE // don't get pushed around
	hud_possible = list()
	ear_deaf = 1000 // so we don't hear unnecessary sounds

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
			stat("Players Ready:", "[SSticker.totalPlayersReady]")
			for(var/datum/job/J as anything in SSjob.active_occupations)
				var/job_occupations = 0
				for(var/mob/dead/new_player/player in global.new_player_list)
					if((player.client == null) || (player.ready != TRUE))
						continue
					if((!istype(J, /datum/job/assistant)) && (player.client.prefs.job_preferences["Assistant"] != JP_LOW) && (player.client.prefs.job_preferences[J.title] == JP_HIGH))
						job_occupations += 1
					else if(istype(J, /datum/job/assistant) && (player.client.prefs.job_preferences[J.title] == JP_LOW)) // assistant > other jobs
						job_occupations += 1
				if(job_occupations >= 1)
					if(J.total_positions == -1)
						stat("[J.title]", "[job_occupations]/∞")
					else
						stat("[J.title]", "[job_occupations]/[J.total_positions]")


/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr || !client)
		return

	if(href_list["lobby_changelog"])
		client.changes()
		return

	if(href_list["lobby_profile"])
		var/datum/profile_settings/profile = new()
		profile.tgui_interact(src)
		return

	if(href_list["lobby_setup"])
		client << browse_rsc('html/prefs/dossier_empty.png')
		client << browse_rsc('html/prefs/opacity7.png')
		client.prefs.ShowChoices(src)
		return

	if(href_list["lobby_ready"])
		if(config.alt_lobby_menu)
			return
		if(config.guest_mode <= GUEST_LOBBY && IsGuestKey(key))
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
		if(config.guest_mode <= GUEST_LOBBY && IsGuestKey(key))
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
		if(config.guest_mode <= GUEST_LOBBY && IsGuestKey(key))
			return
		if(!(ckey in admin_datums) && jobban_isbanned(src, "Observer"))
			to_chat(src, "<span class='red'>You have been banned from observing. Declare yourself.</span>")
			return
		if(!SSmapping.station_loaded)
			to_chat(src, "<span class='red'>There is no station yet, please wait.</span>")
			return
		if(tgui_alert(src,"Are you sure you wish to observe? You will have to wait [config.deathtime_required / 600] minutes before being able to respawn!","Player Setup", list("Yes","No")) == "Yes")
			if(!client)
				return
			spawn_as_observer()

			return

	if(href_list["lobby_join"])
		if(config.alt_lobby_menu)
			return
		if(config.guest_mode <= GUEST_LOBBY && IsGuestKey(key))
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
		if(config.guest_mode <= GUEST_LOBBY && IsGuestKey(key))
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
	if(!SSjob.IsJobAvailable(src, rank))
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
		character.client.prefs.guard.time_velocity_spawn = world.timeofday

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

	var/job_data = ""
	for(var/department_tag in SSjob.departments_occupations)
		var/department_data = ""
		for(var/job_tag in SSjob.departments_occupations[department_tag])
			var/datum/job/J = SSjob.name_occupations[job_tag]
			if(!SSjob.IsJobAvailable(src, J.title))
				continue

			var/quota_class
			switch(J.quota)
				if(QUOTA_WANTED)
					quota_class = "jobPosition--wanted"
				if(QUOTA_UNWANTED)
					quota_class = "jobPosition--unwanted"

			var/head_class
			if(J.title in SSjob.heads_positions)
				head_class = "jobPosition--command"

			department_data += "<a class='jobPosition [quota_class] [head_class]' href='byond://?src=\ref[src];SelectedJob=[J.title]'>[J.title]"
			if(J.current_positions)
				department_data += " ([J.current_positions])<br><i>(Active: [SSjob.GetActiveCount(J.title)])</i>"
			department_data += "</a>"
		if(length(department_data))
			var/datum/department/D = SSjob.name_departments[department_tag]
			job_data += "<fieldset class='jobsColumn' style='border: 2px solid [D.color];'><legend align='center' style='color: [D.color]'>[D.title]</legend>[department_data]</fieldset>"

	if(length(job_data))
		dat += "<div class='clearBoth'>Choose from the following open positions:</div>"
		dat += "<div class='jobsTable'>[job_data]</div>"
	else
		dat += "<div class='notice red'>There are currently no open positions!</div>"

	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 680, 700)
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
		new_character.randomize_appearance()
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

	// little randomize hunger parameters
	new_character.nutrition = rand(NUTRITION_LEVEL_NORMAL, NUTRITION_LEVEL_WELL_FED)
	// random individual metabolism mod from -10% to +10%
	// so people don't get hungry at the same time
	// but it affects all metabolism including chemistry, so i don't know if we need it
	new_character.mob_metabolism_mod.ModAdditive(rand(-10, 10) * 0.01, "Unique character mod")

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
