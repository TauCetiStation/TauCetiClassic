/mob/living/simple_animal/replicator/say(message)
	if(stat != CONSCIOUS)
		return

	message = sanitize(message)

	if(!message)
		return

	if(message[1] == "*")
		return emote(copytext(message, 2))

	message = add_period(capitalize(trim(message)))

	var/image/I = image('icons/mob/talk.dmi', src, "[typing_indicator_type][say_test(message)]", MOB_LAYER + 1)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	flick_overlay_view(I, src, 30)

	emote("beep")

	global.replicators_faction.announce_swarm(global.replicators_faction.get_presence_name(ckey), ckey, message, announcer=src)

/datum/faction/replicators/proc/announce_swarm(presence_name, presence_ckey, message, atom/announcer=null)
	var/list/listening = list()

	for(var/mob/M as anything in mob_list)
		if(!M.client)
			continue

		if(M.mind && M.mind.GetRole(REPLICATOR))
			listening |= M

		else if(isobserver(M))
			listening |= M

	for(var/m in listening)
		var/mob/M = m
		var/open_tags = ""
		var/close_tags = ""

		if(swarms_goodwill[presence_ckey] && swarms_goodwill[max_goodwill_ckey])
			var/goodwill_coeff = swarms_goodwill[presence_ckey] / swarms_goodwill[max_goodwill_ckey]
			var/goodwill_font_size = max(round(goodwill_coeff * 3), 1)

			if(presence_ckey == max_goodwill_ckey)
				open_tags += "<font size='[goodwill_font_size]'>"
				close_tags += "</font>"

		if(presence_name == "The Swarm")
			open_tags += "<font size='5'>"
			close_tags += "</font>"

		var/message_open_tags = "<span class='message'><span class='replicator'>"
		var/message_close_tags = "</span></span>"

		if(announcer && get_dist(announcer, M) < 7)
			message_open_tags += "<b>"
			message_close_tags = "</b>[message_close_tags]"

		var/channel = "<span class='replicator'>\[???\]</span>"
		var/speaker_name = "<b>[presence_name]</b>"

		var/jump_button = ""
		if(announcer && isreplicator(M))
			jump_button = "<a href='?src=\ref[announcer];replicator_jump=1'>(JMP)</a>"

		if(isobserver(M))
			speaker_name = "[FOLLOW_LINK(M, announcer)] [speaker_name]"

		to_chat(M, "[open_tags][channel] [speaker_name] announces, [message_open_tags]\"[message]\"[message_close_tags][close_tags][jump_button]")

// Mines currently also use this.
/datum/faction/replicators/proc/drone_message(atom/drone, message, transfer=FALSE, dismantle=FALSE)
	for(var/r in members)
		var/datum/role/replicator/R = r
		if(!R.antag)
			continue
		var/jump_button = transfer ? "<a href='?src=\ref[drone];replicator_jump=1'>(JMP)</a>" : ""
		var/dismantle_button = dismantle ? "<a href='?src=\ref[drone];replicator_kill=1'>(KILL)</a>" : ""
		to_chat(R.antag.current, "<span class='replicator'>\[???\]</span> <b>[drone.name]</b> requests, <span class='message'><span class='replicator'>\"[message]\"</span></span>[jump_button][dismantle_button]")
