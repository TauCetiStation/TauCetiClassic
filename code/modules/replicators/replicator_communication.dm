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

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.announce_swarm(last_controller_ckey, message, announcer=src)

/datum/faction/replicators/proc/swarm_chat_message(presence_name, message, font_size, announcer=null)
	var/list/listening = list()

	for(var/mob/M as anything in mob_list)
		if(!M.client)
			continue

		if(M.mind && M.mind.GetRole(REPLICATOR))
			listening |= M

		else if(isobserver(M))
			listening |= M

	var/all_open_tags = "<font size='[font_size]'>"
	var/all_close_tags = "</font>"

	for(var/m in listening)
		var/mob/M = m
		var/open_tags = all_open_tags
		var/close_tags = all_close_tags

		var/message_open_tags = "<span class='message'><span class='replicator'>"
		var/message_close_tags = "</span></span>"

		if(announcer && get_dist(announcer, M) < 7)
			message_open_tags += "<b>"
			message_close_tags = "</b>[message_close_tags]"

		var/channel = "<span class='replicator'>\[???\]</span>"
		var/speaker_name = "<b>[presence_name]</b>"

		var/jump_button = ""
		if(announcer && isreplicator(M))
			jump_button = " <a href='?src=\ref[announcer];replicator_jump=1'>(JMP)</a>"

		if(isobserver(M))
			speaker_name = "[FOLLOW_LINK(M, announcer)] [speaker_name]"

		to_chat(M, "[open_tags][channel] [speaker_name] announces, [message_open_tags]\"[message]\"[message_close_tags][close_tags][jump_button]")

/datum/faction/replicators/proc/announce_swarm(presence_ckey, message, atom/announcer=null)
	var/font_size = 2.0

	var/datum/replicator_array_info/RAI = ckey2info[presence_ckey]
	var/datum/replicator_array_info/RAI_max = ckey2info[max_goodwill_ckey]

	if(RAI_max && RAI_max.swarms_goodwill > 0.0)
		var/goodwill_coeff = RAI.swarms_goodwill / RAI_max.swarms_goodwill
		var/goodwill_font_size = clamp(CEIL(goodwill_coeff * 3.0) + 1.0, 2.0, 4.0)

		font_size = goodwill_font_size

	swarm_chat_message(RAI.presence_name, message, font_size, announcer=announcer)

// Mines currently also use this.
/datum/faction/replicators/proc/drone_message(atom/drone, message, transfer=FALSE, dismantle=FALSE, objection_time=0)
	if(isreplicator(drone))
		var/mob/living/simple_animal/replicator/R = drone
		R.objection_end_time = world.time + objection_time

	for(var/r in members)
		var/datum/role/replicator/R = r
		if(!R.antag)
			continue
		var/jump_button = transfer ? " <a href='?src=\ref[drone];replicator_jump=1'>(JMP)</a>" : ""
		var/dismantle_button = dismantle ? " <a href='?src=\ref[drone];replicator_kill=1'>(KILL)</a>" : ""
		var/objection_button = objection_time > 0 ? " <a href='?src=\ref[drone];replicator_objection=1'>(OBJ)</a>" : ""
		to_chat(R.antag.current, "<span class='replicator'>\[???\]</span> <b>[drone.name]</b> requests, <span class='message'><span class='replicator'>\"[message]\"</span></span>[jump_button][dismantle_button][objection_button]")
