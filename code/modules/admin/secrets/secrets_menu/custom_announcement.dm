/* Custom Announcements UI */

var/list/announcement_sounds_cache = list()
var/list/datum/announcement/announcements_list

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
		"funevent" = holder.rights & (R_EVENT | R_FUN),
		"sound" = holder.rights & R_SOUNDS
	)
	return data

/datum/secrets_menu/custom_announce/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("title")
			A.title = sanitize_safe(input(ui.user, "Pick a title for the report.", "Title", A.title) as text)
		if("subtitle")
			A.subtitle = sanitize_safe(input(ui.user, "Pick a subtitle for the report.", "Subtitle", A.subtitle) as text)
		if("message")
			A.message = sanitize(input(ui.user, "Please enter anything you want. Anything. Serious.", "What?", A.message) as message, MAX_PAPER_MESSAGE_LEN, extra = TRUE)
		if("announcer")
			A.announcer = sanitize_safe(input(ui.user, "Pick a announcer for the report.", "Announcer", A.announcer) as text)
		if("flag_text")
			A.flags ^= ANNOUNCE_TEXT
		if("flag_sound")
			A.flags ^= ANNOUNCE_SOUND
		if("flag_comms")
			A.flags ^= ANNOUNCE_COMMS
		if("sound_select")
			var/list/variants = list() + announcement_sounds
			if(holder.rights & R_SOUNDS)
				variants += announcement_sounds_cache
			var/user_input = input(ui.user, "Choose a sound for announce.", "Sound", A.sound) as anything in sortList(variants)
			A.sound = user_input
		if("sound_upload")
			if(!(holder.rights & R_SOUNDS))
				return
			var/sound/S = input("Select a sound from the local repository") as null|sound
			if(!isfile(S))
				return
			var/user_input = sanitize_safe(input(ui.user, "Pick a name for this sound.", "Announcer") as text)
			if(!user_input)
				return
			while (user_input in (announcement_sounds + announcement_sounds_cache))
				user_input = sanitize_safe(input(ui.user, "This sound name is already taken. Please, select another name.", "Announcer") as text)
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
			var/variants = announcement_sounds + announcement_sounds_cache
			if(sound_name in variants)
				sound_file = variants[sound_name]
				if(islist(sound_file))
					sound_file = pick(sound_file)
			else
				WARNING("No sound file for [sound_name]")
			ui.user.playsound_local(null, sound_file, VOL_EFFECTS_VOICE_ANNOUNCEMENT, volume, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)
		if("preset_select")
			if(!(holder.rights & (R_FUN | R_EVENT)))
				return
			var/list/announcement_types = typesof(/datum/announcement)

			if (!announcements_list)
				announcements_list = list()
				for(var/announcement_type in announcement_types)
					var/datum/announcement/A = announcement_type
					if(initial(A.name))
						announcements_list[initial(A.name)] = A
				announcements_list = sortList(announcements_list)

			var/user_input = input(ui.user, "Choose a template.", "Template", A.name) as anything in announcements_list
			A.copy(announcements_list[user_input])
		if("announce")
			if(tgui_alert(usr, "Are you sure?", "Announcement", list("Yes", "No")) == "Yes")
				A.play()
				log_admin("[key_name(ui.user)] has created a command report with sound [A.sound]. [A.title] - [A.subtitle]: [A.message].")
				message_admins("[key_name_admin(ui.user)] has created a command report.")
