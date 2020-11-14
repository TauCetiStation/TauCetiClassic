/* Custom Announcements UI */

var/list/announcement_sounds_cache = list()

/datum/secrets_menu/custom_announce
	title = "Custom Announce"
	name = "CustomAnnounce"
	var/datum/announcement/A

/datum/secrets_menu/custom_announce/New()
	. = ..()
	A = new /datum/announcement/centcomm/admin

/datum/secrets_menu/custom_announce/tgui_data(mob/user)
	var/list/data = list()

	data["title"] = A.title
	data["subtitle"] = A.subtitle
	data["message"] = A.message
	data["announcer"] = A.announcer
	data["sound"] = A.sound
	data["volume"] = A.volume
	data["flags"] = list(
		"text" = A.flags & ANNOUNCE_TEXT,
		"sound" = A.flags & ANNOUNCE_SOUND,
		"comms" = A.flags & ANNOUNCE_COMMS,
	)
	data["rights"] = list(
		"funevent" = admin.client.holder.rights & (R_EVENT | R_FUN),
		"sound" = admin.client.holder.rights & R_SOUNDS
	)
	return data

/datum/secrets_menu/custom_announce/tgui_act(action, list/params)
	. = ..()
	if(.)
		return
	
	switch(action)
		if("title")
			A.title = sanitize_safe(input(admin, "Pick a title for the report.", "Title", A.title) as text)
		if("subtitle")
			A.subtitle = sanitize_safe(input(admin, "Pick a subtitle for the report.", "Subtitle", A.subtitle) as text)
		if("message")
			A.message = sanitize(input(admin, "Please enter anything you want. Anything. Serious.", "What?", A.message) as message, MAX_PAPER_MESSAGE_LEN, extra = TRUE)
		if("announcer")
			A.announcer = sanitize_safe(input(admin, "Pick a announcer for the report.", "Announcer", A.announcer) as text)
		if("flag_text")
			A.flags ^= ANNOUNCE_TEXT
		if("flag_sound")
			A.flags ^= ANNOUNCE_SOUND
		if("flag_comms")
			A.flags ^= ANNOUNCE_COMMS
		if("sound_select")
			var/list/variants = announcement_sounds
			if(admin.client.holder.rights & R_SOUNDS)
				variants += announcement_sounds_cache
			var/user_input = input(admin, "Choose a sound for announce.", "Sound", A.sound) as anything in variants
			A.sound = user_input
		if("sound_upload")
			if(!(admin.client.holder.rights & R_SOUNDS))
				return
			var/sound/S = input("Select a sound from the local repository") as null|sound
			if(!isfile(S))
				return
			var/user_input = sanitize_safe(input(admin, "Pick a name for this sound.", "Announcer") as text)
			if(!user_input)
				return
			announcement_sounds_cache[user_input] = S
			A.sound = user_input
		if("volume")
			A.volume = params["volume"]
		if("test")
			var/sound_name
			var/sound_file
			var/volume
			switch(params["source"])
				if("admin")
					sound_name = A.sound
					volume = A.volume
				if("sample")
					sound_name = "commandreport"
					volume = 100
			if(sound_name in announcement_sounds)
				sound_file = announcement_sounds[sound_name]
				if(islist(sound_file))
					sound_file = pick(sound_file)
			else
				WARNING("No sound file for [sound_name]")
			admin.playsound_local(null, sound_file, VOL_EFFECTS_VOICE_ANNOUNCEMENT, volume, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)
		if("preset_select")
			if(!(admin.client.holder.rights & (R_FUN | R_EVENT)))
				return
			var/list/announcement_types = typesof(/datum/announcement) - base_announcement_types
			var/list/datum/announcement/announcements = list()
			for(var/announcement_type in announcement_types)
				var/datum/announcement/A = new announcement_type
				announcements[A.name] = A
			announcements = sortList(announcements)
			var/user_input = input(admin, "Choose a template.", "Template", A.name) as anything in announcements
			A.copy(announcements[user_input])
		if("announce")
			if(alert("Are you sure?", "Announcement", "Yes", "No") == "Yes")
				A.play()
				log_admin("[key_name(admin)] has created a command report with sound [A.sound]. [A.title] - [A.subtitle]: [A.message].")
				message_admins("[key_name_admin(admin)] has created a command report.")
