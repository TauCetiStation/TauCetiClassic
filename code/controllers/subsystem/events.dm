SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = SS_INIT_EVENTS
	runlevels = RUNLEVEL_GAME
	// Report events at the end of the rouund
	var/report_at_round_end = 0

    // Event vars
	var/datum/event_container/selected_event_container = null
	var/list/active_events = list()
	var/list/finished_events = list()
	var/list/allEvents = list()
	var/list/event_containers = list(
			EVENT_LEVEL_FEATURE    = new/datum/event_container/feature,
			EVENT_LEVEL_MUNDANE    = new/datum/event_container/mundane,
			EVENT_LEVEL_MODERATE   = new/datum/event_container/moderate,
			EVENT_LEVEL_MAJOR      = new/datum/event_container/major,
		)

	var/datum/event_meta/new_event = new

	var/list/allowed_areas_for_events

	var/custom_event_msg
	var/custom_event_mode

/datum/controller/subsystem/events/Initialize()
	var/list/black_types = list(
			/datum/event/anomaly,
			/datum/event/feature,
			/datum/event/feature/area,
			/datum/event/feature/area/mess,
			/datum/event/feature/area/replace,
			/datum/event/feature/area/maintenance_spawn,
	)
	allEvents = subtypesof(/datum/event) - black_types

	collectEventAreas()
	return ..()

/datum/controller/subsystem/events/fire()
	for(var/datum/event/E in active_events)
		E.process(wait * 0.1)

	for(var/i in EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
		var/datum/event_container/EC = event_containers[i]
		EC.process(wait * 0.1)

/datum/controller/subsystem/events/proc/start_roundstart_event()
	if(!config.allow_random_events)
		message_admins("RoundStart Event: No event, random events has been disabled by SERVER.")
		return
	var/datum/event_container/feature/EC = event_containers[EVENT_LEVEL_FEATURE]
	for(var/i in 1 to rand(1, 3))
		EC.start_event()

/datum/controller/subsystem/events/proc/event_complete(datum/event/E)
	if(!E.event_meta)	// datum/event is used here and there for random reasons, maintaining "backwards compatibility"
		log_debug("Event of '[E.type]' with missing meta-data has completed.")
		return

	finished_events += E

	var/theseverity

	if(!E.severity)
		theseverity = EVENT_LEVEL_MODERATE

	if(E.severity != EVENT_LEVEL_FEATURE && E.severity != EVENT_LEVEL_MUNDANE && E.severity != EVENT_LEVEL_MODERATE && E.severity != EVENT_LEVEL_MAJOR)
		theseverity = EVENT_LEVEL_MODERATE //just to be careful

	if(E.severity)
		theseverity = E.severity

	// Add the event back to the list of available events
	var/datum/event_container/EC = event_containers[theseverity]
	var/datum/event_meta/EM = E.event_meta
	EC.available_events += EM

	log_debug("Event '[EM.name]' has completed at [worldtime2text()].")

/datum/controller/subsystem/events/proc/delay_events(severity, delay)
	var/datum/event_container/EC = event_containers[severity]
	EC.next_event_time += delay

/datum/controller/subsystem/events/proc/Interact(mob/living/user)

	var/html = GetInteractWindow()

	var/datum/browser/popup = new(user, "event_manager", "Event Manager", 700, 600)
	popup.set_content(html)
	popup.open()

/datum/controller/subsystem/events/proc/RoundEnd()
	if(!report_at_round_end)
		return

	to_chat(world, "<br><br><br><font size=3><b>Random Events This Round:</b></font>")
	for(var/datum/event/E in active_events|finished_events)
		var/datum/event_meta/EM = E.event_meta
		if(EM.name == "Nothing")
			continue
		var/message = "'[EM.name]' began at [worldtime2text(E.startedAt)] "
		if(E.isRunning)
			message += "and is still running."
		else
			if(E.endedAt - E.startedAt > 5 MINUTES) // Only mention end time if the entire duration was more than 5 minutes
				message += "and ended at [worldtime2text(E.endedAt)]."
			else
				message += "and ran to completion."

		to_chat(world, message)

/datum/controller/subsystem/events/proc/GetInteractWindow()
	var/html = "<A align='right' href='?src=\ref[src];refresh=1'>Refresh</A>"
	if(!config.allow_random_events)
		html = "<span class='red'>Random events has been disabled by SERVER!</span><br>" + html
	else
		var/pause_all = FALSE
		for(var/severity in EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
			var/datum/event_container/EC = event_containers[severity]
			if(!EC.delayed)
				pause_all = TRUE
				break
		html += "<A align='right' href='?src=\ref[src];pause_all=[pause_all ? "Pause" : "Resume"]'>[pause_all ? "Pause" : "Resume"] All</A><br>"

	if(selected_event_container)
		var/event_time = max(0, selected_event_container.next_event_time - world.time)
		html += "<A align='right' href='?src=\ref[src];back=1'>Back</A><br>"
		html += "Time till start: [round(event_time / 600, 0.1)]<br>"
		html += "<div class='Section'>"
		html += "<h2>Available [severity_to_string[selected_event_container.severity]] Events (queued & running events will not be displayed)</h2>"
		html += "<table align='center'>"
		html += "<tr><th class='collapsing'>Name</th><th>Weight</th><th>MinWeight</th><th>MaxWeight</th><th>OneShot</th><th>Enabled</th><th><span class='red'>CurrWeight</span></th><th>Remove</th></tr>"
		for(var/datum/event_meta/EM in selected_event_container.available_events)
			html += "<tr>"
			html += "<td>[EM.name]</td>"
			html += "<td><A align='right' href='?src=\ref[src];set_weight=\ref[EM]'>[EM.weight]</A></td>"
			html += "<td>[EM.min_weight]</td>"
			html += "<td>[EM.max_weight]</td>"
			html += "<td><A align='right' href='?src=\ref[src];toggle_oneshot=\ref[EM]'>[EM.one_shot]</A></td>"
			html += "<td><A align='right' href='?src=\ref[src];toggle_enabled=\ref[EM]'>[EM.enabled]</A></td>"
			html += "<td><span class='red'>[EM.get_weight(number_active_with_role())]</span></td>"
			html += "<td><A align='right' href='?src=\ref[src];remove=\ref[EM];EC=\ref[selected_event_container]'>Remove</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

		html += "<div class='Section'>"
		html += "<h2>Add Event</h2>"
		html += "<table align='center'>"
		html += "<tr><th>Name</th><th class='collapsing'>Type</th><th class='collapsing'>Weight</th><th class='collapsing'>OneShot</th></tr>"
		html += "<tr>"
		html += "<td><A align='right' href='?src=\ref[src];set_name=\ref[new_event]'>[new_event.name ? new_event.name : "Enter Event"]</A></td>"
		html += "<td><A align='right' href='?src=\ref[src];set_type=\ref[new_event]'>[new_event.event_type ? new_event.event_type : "Select Type"]</A></td>"
		html += "<td><A align='right' href='?src=\ref[src];set_weight=\ref[new_event]'>[new_event.weight ? new_event.weight : 0]</A></td>"
		html += "<td><A align='right' href='?src=\ref[src];toggle_oneshot=\ref[new_event]'>[new_event.one_shot]</A></td>"
		html += "</tr>"
		html += "</table>"
		html += "<A align='right' href='?src=\ref[src];add=\ref[selected_event_container]'>Add</A><br>"
		html += "</div>"
	else
		html += "<A align='right' href='?src=\ref[src];toggle_report=1'>Round End Report: [report_at_round_end ? "On": "Off"]</A><br>"
		html += "<div class='Section'>"
		html += "<h2>Event Start</h2>"

		html += "<table align='center'>"
		html += "<tr><th>Severity</th><th class='collapsing'>Starts At</th><th class='collapsing'>Starts In</th><th class='collapsing'>Adjust Start</th><th class='collapsing'>Pause</th><th class='collapsing'>Interval Mod</th></tr>"
		for(var/severity in EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
			var/datum/event_container/EC = event_containers[severity]
			var/next_event_at = max(0, EC.next_event_time - world.time)
			html += "<tr>"
			html += "<td>[severity_to_string[severity]]</td>"
			html += "<td>[worldtime2text(max(EC.next_event_time, world.time))]</td>"
			html += "<td>[round(next_event_at / 600, 0.1)]</td>"
			html += "<td>"
			html +=   "<A align='right' href='?src=\ref[src];dec_timer=2;event=\ref[EC]'>--</A>"
			html +=   "<A align='right' href='?src=\ref[src];dec_timer=1;event=\ref[EC]'>-</A>"
			html +=   "<A align='right' href='?src=\ref[src];inc_timer=1;event=\ref[EC]'>+</A>"
			html +=   "<A align='right' href='?src=\ref[src];inc_timer=2;event=\ref[EC]'>++</A>"
			html += "</td>"
			html += "<td>"
			html +=   "<A align='right' href='?src=\ref[src];pause=\ref[EC]'>[EC.delayed ? "Resume" : "Pause"]</A>"
			html += "</td>"
			html += "<td>"
			html +=   "<A align='right' href='?src=\ref[src];interval=\ref[EC]'>[EC.delay_modifier]</A>"
			html += "</td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

		html += "<div class='Section'>"
		html += "<h2>Next Event</h2>"
		html += "<table align='center'>"
		html += "<tr><th>Severity</th><th class='collapsing'>Name</th><th class='collapsing'>Event Rotation</th><th class='collapsing'>Clear</th></tr>"
		for(var/severity in EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
			var/datum/event_container/EC = event_containers[severity]
			var/datum/event_meta/EM = EC.next_event
			html += "<tr>"
			html += "<td>[severity_to_string[severity]]</td>"
			html += "<td><A align='right' href='?src=\ref[src];select_event=\ref[EC]'>[EM ? EM.name : "Random"]</A></td>"
			html += "<td><A align='right' href='?src=\ref[src];view_events=\ref[EC]'>View</A></td>"
			html += "<td><A align='right' href='?src=\ref[src];clear=\ref[EC]'>Clear</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

		html += "<div class='Section'>"
		html += "<h2>Running Events</h2>"
		html += "Estimated times, affected by master controller delays."
		html += "<table align='center'>"
		html += "<tr><th>Severity</th><th class='collapsing'>Name</th><th class='collapsing'>Ends At</th><th class='collapsing'>Ends In</th><th class='collapsing'>Stop</th></tr>"
		for(var/datum/event/E in active_events)
			if(!E.event_meta)
				continue
			var/datum/event_meta/EM = E.event_meta
			var/ends_at = E.startedAt + (E.lastProcessAt() * 20)	// A best estimate, based on how often the manager processes
			var/ends_in = max(0, round((ends_at - world.time) / 600, 0.1))
			var/no_end = E.noAutoEnd
			html += "<tr>"
			html += "<td>[severity_to_string[EM.severity]]</td>"
			html += "<td>[EM.name]</td>"
			html += "<td>[no_end ? "N/A" : worldtime2text(ends_at)]</td>"
			html += "<td>[no_end ? "N/A" : ends_in]</td>"
			html += "<td><A align='right' href='?src=\ref[src];stop=\ref[E]'>Stop</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

	return html

/datum/controller/subsystem/events/Topic(href, href_list)
	if(..())
		return

	if(!check_rights(R_ADMIN))
		return


	if(href_list["toggle_report"])
		report_at_round_end = !report_at_round_end
		admin_log_and_message_admins("has [report_at_round_end ? "enabled" : "disabled"] the round end event report.")
	else if(href_list["dec_timer"])
		var/datum/event_container/EC = locate(href_list["event"])
		var/decrease = 60 * 10**text2num(href_list["dec_timer"])
		EC.next_event_time -= decrease
		admin_log_and_message_admins("decreased timer for [severity_to_string[EC.severity]] events by [decrease/600] minute(s).")
	else if(href_list["inc_timer"])
		var/datum/event_container/EC = locate(href_list["event"])
		var/increase = 60 * 10**text2num(href_list["inc_timer"])
		EC.next_event_time += increase
		admin_log_and_message_admins("increased timer for [severity_to_string[EC.severity]] events by [increase/600] minute(s).")
	else if(href_list["select_event"])
		var/datum/event_container/EC = locate(href_list["select_event"])
		var/datum/event_meta/EM = EC.SelectEvent()
		if(EM)
			admin_log_and_message_admins("has queued the [severity_to_string[EC.severity]] event '[EM.name]'.")
	else if(href_list["pause"])
		var/datum/event_container/EC = locate(href_list["pause"])
		EC.delayed = !EC.delayed
		admin_log_and_message_admins("has [EC.delayed ? "paused" : "resumed"] countdown for [severity_to_string[EC.severity]] events.")
	else if(href_list["pause_all"])
		var/pause_all
		switch(href_list["pause_all"])
			if("Pause")
				pause_all = TRUE
			if("Resume")
				pause_all = FALSE
		for(var/severity in EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
			var/datum/event_container/EC = event_containers[severity]
			EC.delayed = pause_all
		admin_log_and_message_admins("has [pause_all ? "paused" : "resumed"] countdown for all events.")
	else if(href_list["interval"])
		var/delay = input("Enter delay modifier. A value less than one means events fire more often, higher than one less often.", "Set Interval Modifier") as num|null
		if(delay && delay > 0)
			var/datum/event_container/EC = locate(href_list["interval"])
			EC.delay_modifier = delay
			admin_log_and_message_admins("has set the interval modifier for [severity_to_string[EC.severity]] events to [EC.delay_modifier].")
	else if(href_list["stop"])
		if(tgui_alert(usr, "Stopping an event may have unintended side-effects. Continue?", "Stopping Event!", list("Yes","No")) != "Yes")
			return
		var/datum/event/E = locate(href_list["stop"])
		var/datum/event_meta/EM = E.event_meta
		admin_log_and_message_admins("has stopped the [severity_to_string[EM.severity]] event '[EM.name]'.")
		E.kill()
	else if(href_list["view_events"])
		selected_event_container = locate(href_list["view_events"])
	else if(href_list["back"])
		selected_event_container = null
	else if(href_list["set_name"])
		var/name = sanitize(input("Enter event name.", "Set Name") as text|null)
		if(name)
			var/datum/event_meta/EM = locate(href_list["set_name"])
			EM.name = name
	else if(href_list["set_type"])
		var/type = input("Select event type.", "Select") as null|anything in allEvents
		if(type)
			var/datum/event_meta/EM = locate(href_list["set_type"])
			EM.event_type = type
	else if(href_list["set_weight"])
		var/weight = input("Enter weight. A higher value means higher chance for the event of being selected.", "Set Weight") as num|null
		if(weight && weight > 0)
			var/datum/event_meta/EM = locate(href_list["set_weight"])
			EM.weight = weight
			if(EM != new_event)
				admin_log_and_message_admins("has changed the weight of the [severity_to_string[EM.severity]] event '[EM.name]' to [EM.weight].")
	else if(href_list["toggle_oneshot"])
		var/datum/event_meta/EM = locate(href_list["toggle_oneshot"])
		EM.one_shot = !EM.one_shot
		if(EM != new_event)
			admin_log_and_message_admins("has [EM.one_shot ? "set" : "unset"] the oneshot flag for the [severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["toggle_enabled"])
		var/datum/event_meta/EM = locate(href_list["toggle_enabled"])
		EM.enabled = !EM.enabled
		admin_log_and_message_admins("has [EM.enabled ? "enabled" : "disabled"] the [severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["remove"])
		if(tgui_alert(usr, "This will remove the event from rotation. Continue?", "Removing Event!", list("Yes","No")) != "Yes")
			return
		var/datum/event_meta/EM = locate(href_list["remove"])
		var/datum/event_container/EC = locate(href_list["EC"])
		EC.available_events -= EM
		admin_log_and_message_admins("has removed the [severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["add"])
		if(!new_event.name || !new_event.event_type)
			return
		if(tgui_alert(usr, "This will add a new event to the rotation. Continue?", "Add Event!", list("Yes","No")) != "Yes")
			return
		new_event.severity = selected_event_container.severity
		selected_event_container.available_events += new_event
		admin_log_and_message_admins("has added \a [severity_to_string[new_event.severity]] event '[new_event.name]' of type [new_event.event_type] with weight [new_event.weight].")
		new_event = new
	else if(href_list["clear"])
		var/datum/event_container/EC = locate(href_list["clear"])
		if(EC.next_event)
			admin_log_and_message_admins("has dequeued the [severity_to_string[EC.severity]] event '[EC.next_event.name]'.")
			EC.next_event = null

	Interact(usr)

/datum/controller/subsystem/events/proc/collectEventAreas()
	if(!allowed_areas_for_events)
		//Places that shouldn't explode
		var/list/safe_areas = typecacheof(list(
			/area/station/ai_monitored/storage_secure,
			/area/station/aisat/ai_chamber,
			/area/station/bridge/ai_upload,
			/area/station/engineering,
			/area/station/solar,
			/area/station/civilian/holodeck,
			))

		//Subtypes from the above that actually should explode.
		var/list/unsafe_areas =  typecacheof(list(
			/area/station/engineering/break_room,
			/area/station/engineering/chiefs_office,
			))

		allowed_areas_for_events = make_associative(subtypesof(/area/station)) - safe_areas + unsafe_areas

/datum/controller/subsystem/events/proc/findEventArea()
	var/list/possible_areas = typecache_filter_list(global.all_areas, allowed_areas_for_events)
	if(length(possible_areas))
		return pick(possible_areas)

/datum/controller/subsystem/events/proc/setup_custom_event(text, mode)
	custom_event_msg = text
	custom_event_mode = mode

	custom_event_announce()

/datum/controller/subsystem/events/proc/custom_event_announce(user)
	if(!custom_event_msg)
		return

	var/target = user || world

	var/message = {"<h1 class='alert'>Custom Event</h1><br>
<h2 class='alert'>A custom event is taking place. OOC Info:</h2><br>
<span class='alert linkify'>[custom_event_msg]</span><br>
<br>"}

	to_chat(target, message)

/datum/controller/subsystem/events/proc/custom_event_announce_bridge()
	if(config.chat_bridge && custom_event_msg)
		world.send2bridge(
			type = list(BRIDGE_ANNOUNCE),
			attachment_title = "Custom Event",
			attachment_msg = custom_event_msg + "\nJoin now: <[BYOND_JOIN_LINK]>",
			attachment_color = BRIDGE_COLOR_ANNOUNCE,
			mention = BRIDGE_MENTION_EVENT,
		)
