/mob
	// Memes this mob is sharing via writing/speaking.
	var/list/sharing_memes
	var/datum/browser/memes/my_memes

// Returns the resulting, warped /datum/spoken_info, after speaking all the required memes out loud.
/mob/proc/process_spoken_memes(message, spoken_verb = "says", datum/language/spoken = null, alt_name = "", message_range = world.view)
	var/list/spoken_memes = sharing_memes && sharing_memes[MEME_SPREAD_VERBALLY] ? sharing_memes[MEME_SPREAD_VERBALLY].Copy() : null

	var/datum/spoken_info/SI = new(null, message, src, spoken_verb, spoken, alt_name, message_range)
	var/saved_meme_priority = 0

	for(var/datum/meme/M in spoken_memes)
		var/output = M.on_speak(SI)
		if(!output)
			continue

		if(M.perception_priority > saved_meme_priority)
			SI.merge(output, force = TRUE)
			saved_meme_priority = M.perception_priority
		else
			SI.merge(output)

		if(!M.flags[MEME_FORCE_SPREAD_VERBALLY])
			stop_sharing(M.id, MEME_SPREAD_VERBALLY)

	return SI

/mob/proc/process_heard_memes(list/heard_memes, message, speaker = null, spoken_verb = "says", datum/language/spoken = null, alt_name = "")
	var/datum/spoken_info/SI = new(src, message, speaker, spoken_verb, spoken, alt_name)
	var/saved_meme_priority = 0

	for(var/datum/meme/M in heard_memes)
		var/output = M.on_hear(SI)
		if(!output)
			continue

		if(M.perception_priority > saved_meme_priority)
			SI.merge(output, force = TRUE)
			saved_meme_priority = M.perception_priority
		else
			SI.merge(output)

	return SI

/mob/proc/is_sharing(share_type)
	return sharing_memes && sharing_memes[share_type]

/mob/proc/share_meme(meme_id, share_type)
	var/datum/meme/M = attached_memes[meme_id]
	if(!M)
		return

	if(!sharing_memes)
		sharing_memes = list()
	if(!sharing_memes[share_type])
		sharing_memes[share_type] = list()
	sharing_memes[share_type] += M

/mob/proc/stop_sharing(meme_id, share_type)
	var/datum/meme/M = attached_memes[meme_id]
	if(!M)
		return

	sharing_memes[share_type] -= M
	if(!length(sharing_memes[share_type]))
		sharing_memes -= share_type
	if(!sharing_memes.len)
		sharing_memes = null

/mob/verb/manage_memes()
	set name = "Manage Memes"
	set desc = "Gaze upon the deepest corners of thy mind to see thy everything. The thoughts, the memories, the mind itself, the \"you\"."
	set category = "IC"

	if(!cognitive())
		to_chat(src, "<span class='notice'>This body can not support the constructs of a mind at this moment.</span>")
		return

	if(!browseable_memes)
		to_chat(src, "<span class='notice'>It seems as if I have no memes to manage.</span>")
		return

	if(!my_memes)
		my_memes = new(src, "my_memes", "Fortress of the Mind", 800, 600)
	my_memes.open()

/datum/asset/simple/memes
	assets = list(
		"memetic1.jpg" = 'html/prefs/memetic1.jpg',
		"memetic2.jpg" = 'html/prefs/memetic2.jpg',
		"memetic3.jpg" = 'html/prefs/memetic3.jpg',
		"uiMaskBackground.png" = 'nano/images/uiMaskBackground.png',
		"arrow1.png" = 'html/prefs/arrow1.png',
		"arrow2.png" = 'html/prefs/arrow2.png',
		"header1.jpg" = 'html/prefs/header1.jpg'
	)

/datum/browser/memes
	var/selected_meme_category = ""
	var/selected_meme = ""
	var/search_meme = ""

/datum/browser/memes/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, atom/nref, ntheme)
	..()
	selected_meme_category = pick(user.browseable_memes)
	add_stylesheet("memetic", 'html/browser/memetic.css')
	RegisterSignal(nuser, list(COMSIG_MEME_ADDED, COMSIG_MEME_REMOVED), .proc/update)
	update()

/datum/browser/memes/proc/can_use()
	return user.browseable_memes && user.cognitive()

/datum/browser/memes/proc/update()
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/memes)
	assets.send(user)

	var/dat = ""
	dat += "<div class=\"memeticCategoriesContainer\"><table><tr>"

	for(var/category in user.browseable_memes)
		var/selected = category == selected_meme_category ? "" : "-notSelected"
		dat += "<td style=\"padding:0px;\"><A class=\"memeticCategorySelected[selected]\" href='?src=\ref[src];action=select_category;category=[category]'><b>[category]</b></A></td>"

	dat += "</tr></table></div>"
	dat += "<div class=\"memeticCategoryContainer memeticType-[selected_meme_category]\">"
	dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=search;'>Search:</A> [search_meme] <A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=search;reset=1'>Reset</A>"

	for(var/datum/meme/M in user.browseable_memes[selected_meme_category])
		if(findtext(M.get_name(user), search_meme))
			var/selected = ""
			// If the meme is highlighted, then it stands out among all the others using the frame.
			if(M.id == selected_meme)
				selected = "memeticTypeSelected-[selected_meme_category]"

			dat += "<div class=\"memeticItem [selected_meme_category] memeticType-[selected_meme_category] [selected]\">"
			dat += "<table width=\"100%\">"
			dat += "<tr>"
			dat += "<hr><td style=\"line-height:30px;\" width=\"75%\"><A class=\"memeticButton [M.id == selected_meme ? "select" : ""] memeticIcon memeticType-[selected_meme_category]\" href='?src=\ref[src];action=more_info;block=[M.id]'></A>Name: <A class=\"memeticButton\" href='?src=\ref[src];action=set_name;meme=[M.id]'><b>[user.active_memes && user.active_memes[M.id] ? "(A) " : ""][M.get_name(user)]</b></A></td>"
			dat += "<td>[M.desc]</td>"
			dat += "<div style=\"height:100%; width:100%\"></div>"
			dat += "</tr>"

			if(M.id == selected_meme)
				dat += "<tr>"
				dat += "<td width=\"75%\">[M.long_desc]</td>"
				dat += "<td style=\"line-height:30px;\">"

				if(M.flags[MEME_SPREAD_VERBALLY])
					dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=meme_action;type_action=[MEME_SPREAD_VERBALLY];meme=[M.id]'>Pass on verbally.</A><br>"
				if(M.flags[MEME_SPREAD_READING])
					dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=meme_action;type_action=[MEME_SPREAD_READING];meme=[M.id]'>Write down.</A><br>"
				if(M.can_forget)
					dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=meme_action;type_action=\"Forget\";meme=[M.id]'>Forget.</A><br>"

				dat += "</td>"
				dat += "</tr>"
			dat += "</table>"
			dat += "</div>"
	dat += "</div>"

	set_content(dat)
	open()

/datum/browser/memes/Topic(href, href_list)
	if(!can_use())
		close()
		return

	var/needs_update = FALSE

	switch(href_list["action"])
		if("select_category")
			var/cat = href_list["category"]
			if(cat in user.browseable_memes)
				selected_meme_category = cat
				needs_update = TRUE

		if("more_info")
			var/meme_id = href_list["block"]
			if(user.attached_memes[meme_id])
				if(selected_meme == meme_id)
					selected_meme = null
				else
					selected_meme = meme_id
				needs_update = TRUE

		if("set_name")
			var/meme_id = href_list["meme"]
			var/datum/meme/memory/M = user.attached_memes[meme_id]
			if(istype(M) && !M.hidden)
				var/new_name = sanitize_safe(input(user, "Pick a name.", "Name.", M.get_name(user)) as null|text, 25)
				if(new_name)
					M.display_name[user] = new_name
					needs_update = TRUE

		if("toggle_activation")
			var/meme_id = href_list["meme"]
			var/datum/meme/memory/M = user.attached_memes[meme_id]
			if(istype(M) && !M.hidden)
				if(M.active_for[user])
					user.deactivate_memory(meme_id)
				else
					user.activate_memory(meme_id)

		if("search")
			if(href_list["reset"])
				search_meme = ""
			else
				search_meme = sanitize_safe(input(user, "Search.", "Name.") as null|text, 25)
			needs_update = TRUE

		if("meme_action")
			var/meme_id = href_list["meme"]
			var/datum/meme/M = user.attached_memes[meme_id]
			if(M && !M.hidden)
				switch(href_list["type_action"])
					if(MEME_SPREAD_READING)
						if(M.flags[MEME_SPREAD_READING])
							if(!user.is_sharing(MEME_SPREAD_READING))
								user.share_meme(meme_id, MEME_SPREAD_READING)
								to_chat(user, "<span class='notice'>Now you will try to write [M.get_name(user)] down.</span>")
								needs_update = TRUE
							else
								to_chat(user, "<span class='notice'>You are already trying to write some meme down...</span>")

					if(MEME_SPREAD_VERBALLY)
						if(M.flags[MEME_SPREAD_VERBALLY])
							if(!user.is_sharing(MEME_SPREAD_VERBALLY))
								user.share_meme(meme_id, MEME_SPREAD_VERBALLY)
								to_chat(user, "<span class='notice'>Now you will try to say [M.get_name(user)] out loud.</span>")
								needs_update = TRUE
							else
								to_chat(user, "<span class='notice'>You are already trying to speak some meme out...</span>")

					if("Forget")
						if(M.can_forget)
							user.remove_meme(meme_id)
							needs_update = TRUE

	if(needs_update)
		update()
