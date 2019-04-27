// shows a message inviting ghosts to join the event, calls a callback with a list of observer objects
/datum/catastrophe_join_event
	var/name = "bad event"

	var/list/join_options = list("error")

	var/list/joined = list()

	var/join_time = 45

	var/active = TRUE

	var/datum/callback/callback

/datum/catastrophe_join_event/New(title, list/options, datum/callback/cb)
	name = title
	join_options = options
	callback = cb
	var/options_str = ""
	for(var/option in join_options)
		options_str += "<a href='?src=\ref[src];join=[option]'>[option]</a> "

		joined[option] = list()

	for(var/mob/dead/observer/G	in player_list)
		to_chat(G, "<span class='notice big'>[name]: This event requires players, select one of the options if you want to participate: [options_str]. Event will start in [join_time] seconds</span>")

	addtimer(CALLBACK(src, .proc/end_join_period), 10*join_time)
	addtimer(CALLBACK(src, .proc/last_warning), 10*(join_time - 15))

/datum/catastrophe_join_event/Topic(href, href_list)
	. = ..()

	if(!isobserver(usr))
		return

	if(!active)
		return

	if(href_list["join"])
		var/join_side = href_list["join"]
		if(!(join_side in join_options))
			return

		if(usr in joined[join_side])
			to_chat(usr, "<span class='notice'>You will no longer be considered for the next event</span>")
			joined[join_side] -= usr
			return

		for(var/option in join_options)
			if(usr in joined[option])
				joined[option] -= usr

		to_chat(usr, "<span class='notice'>You will now be considered as '[join_side]' for the next event. There are [joined[join_side].len] allies already</span>")
		joined[join_side] += usr


/datum/catastrophe_join_event/proc/last_warning()
	var/side_numbers = ""
	for(var/option in join_options)
		side_numbers += "<a href='?src=\ref[src];join=[option]'>[option]</a>: [joined[option].len]   "

	for(var/mob/dead/observer/G	in player_list)
		to_chat(G, "<span class='notice big'>[name]: event will start in 15 seconds. [side_numbers]</span>")


/datum/catastrophe_join_event/proc/end_join_period()
	for(var/option in join_options)
		for(var/mob/dead/observer/obs in joined[option])
			if(!obs || !obs.client)
				joined[option] -= obs

	if(callback)
		callback.Invoke(joined)

	joined = null // so we dont keep any references
	active = FALSE