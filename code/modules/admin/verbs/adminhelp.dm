/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/client/var/datum/admin_help/current_ticket

/**
 * # Adminhelp Ticket Manager
 */
var/global/datum/admin_help_tickets/ahelp_tickets

/datum/admin_help_tickets
	/// The set of all active tickets
	var/list/active_tickets = list()
	/// The set of all closed tickets
	var/list/closed_tickets = list()
	/// The set of all resolved tickets
	var/list/resolved_tickets = list()

	var/obj/effect/statclick/ticket_list/astatclick = new(null, null, AHELP_ACTIVE)
	var/obj/effect/statclick/ticket_list/cstatclick = new(null, null, AHELP_CLOSED)
	var/obj/effect/statclick/ticket_list/rstatclick = new(null, null, AHELP_RESOLVED)

	var/list/ckey_cooldown_holder = list()

/datum/admin_help_tickets/Destroy()
	QDEL_LIST(active_tickets)
	QDEL_LIST(closed_tickets)
	QDEL_LIST(resolved_tickets)
	QDEL_NULL(astatclick)
	QDEL_NULL(cstatclick)
	QDEL_NULL(rstatclick)
	return ..()

/datum/admin_help_tickets/proc/TicketsByCKey(ckey)
	. = list()
	var/list/lists = list(active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/datum/admin_help/AH in I)
			if(AH.initiator_ckey == ckey)
				. += AH

//private
/datum/admin_help_tickets/proc/ListInsert(datum/admin_help/new_ticket)
	var/list/ticket_list
	switch(new_ticket.state)
		if(AHELP_ACTIVE)
			ticket_list = active_tickets
		if(AHELP_CLOSED)
			ticket_list = closed_tickets
		if(AHELP_RESOLVED)
			ticket_list = resolved_tickets
		else
			CRASH("Invalid ticket state: [new_ticket.state]")
	var/num_closed = ticket_list.len
	if(num_closed)
		for(var/I in 1 to num_closed)
			var/datum/admin_help/AH = ticket_list[I]
			if(AH.id > new_ticket.id)
				ticket_list.Insert(I, new_ticket)
				return
	ticket_list += new_ticket

//opens the ticket listings for one of the 3 states
/datum/admin_help_tickets/proc/BrowseTickets(state)
	var/list/l2b
	var/title
	switch(state)
		if(AHELP_ACTIVE)
			l2b = active_tickets
			title = "Active Tickets"
		if(AHELP_CLOSED)
			l2b = closed_tickets
			title = "Closed Tickets"
		if(AHELP_RESOLVED)
			l2b = resolved_tickets
			title = "Resolved Tickets"
	if(!l2b)
		return
	var/list/dat = list("<title>[title]</title>")
	dat += "<A href='?_src_=holder;ahelp_tickets=[state]'>Refresh</A><br><br>"
	for(var/I in l2b)
		var/datum/admin_help/AH = I
		dat += "<span class='adminnotice'><span class='adminhelp'>Ticket #[AH.id]</span>: <A href='?_src_=holder;ahelp=\ref[AH];ahelp_action=ticket'>[AH.initiator_key_name]: [AH.name]</A></span><br>"

	var/datum/browser/popup = new(usr, "ahelp_list[state]", null, 600, 480, null, CSS_THEME_LIGHT)
	popup.set_content(dat.Join())
	popup.open()

//Tickets statpanel
/datum/admin_help_tickets/proc/stat_entry()
	var/num_disconnected = 0
	stat("Active Tickets:", astatclick.update("[active_tickets.len]"))
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.initiator)
			stat("#[AH.id]. [AH.initiator_key_name]:", AH.statclick.update())
		else
			++num_disconnected
	if(num_disconnected)
		stat("Disconnected:", astatclick.update("[num_disconnected]"))
	stat("Closed Tickets:", cstatclick.update("[closed_tickets.len]"))
	stat("Resolved Tickets:", rstatclick.update("[resolved_tickets.len]"))

//Reassociate still open ticket if one exists
/datum/admin_help_tickets/proc/ClientLogin(client/C)
	C.current_ticket = CKey2ActiveTicket(C.ckey)
	if(C.current_ticket)
		C.current_ticket.initiator = C
		C.current_ticket.AddInteraction("Client reconnected.")

//Dissasociate ticket
/datum/admin_help_tickets/proc/ClientLogout(client/C)
	if(C.current_ticket)
		C.current_ticket.AddInteraction("Client disconnected.")
		C.current_ticket.initiator = null
		C.current_ticket = null

//Get a ticket given a ckey
/datum/admin_help_tickets/proc/CKey2ActiveTicket(ckey)
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.initiator_ckey == ckey)
			return AH

//
//TICKET LIST STATCLICK
//

/obj/effect/statclick/ticket_list
	var/current_state

/obj/effect/statclick/ticket_list/atom_init(mapload, name, state)
	current_state = state
	. = ..()

/obj/effect/statclick/ticket_list/Click()
	global.ahelp_tickets.BrowseTickets(current_state)

/**
 * # Adminhelp Ticket
 */
/datum/admin_help
	/// Unique ID of the ticket
	var/id
	/// The current name of the ticket
	var/name
	/// The current state of the ticket
	var/state = AHELP_ACTIVE
	/// The time (ticks) at which the ticket was opened
	var/opened_at
	/// The time (ticks) at which the ticket was closed
	var/closed_at
	/// The time (timeofday) at which the ticket was opened
	var/opened_at_server
	/// The time (timeofday) at which the ticket was closed
	var/closed_at_server
	/// Semi-misnomer, it's the person who ahelped/was bwoinked
	var/client/initiator
	/// The ckey of the initiator
	var/initiator_ckey
	/// The key name of the initiator
	var/initiator_key_name
	/// If any admins were online when the ticket was initialized
	var/heard_by_no_admins = FALSE
	/// The collection of interactions with this ticket. Use AddInteraction() or, preferably, admin_ticket_log()
	var/list/_interactions
	/// Statclick holder for the ticket
	var/obj/effect/statclick/ahelp/statclick
	/// Static counter used for generating each ticket ID
	var/static/ticket_counter = 0

/**
 * Call this on its own to create a ticket, don't manually assign current_ticket
 *
 * Arguments:
 * * msg - The title of the ticket: usually the ahelp text
 * * is_bwoink - Boolean operator, TRUE if this ticket was started by an admin PM
 */
/datum/admin_help/New(msg, client/C, is_bwoink)
	if(!msg || !C || !C.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = world.time
	opened_at_server = world.timeofday

	name = msg

	initiator = C
	initiator_ckey = initiator.ckey
	initiator_key_name = key_name(initiator, FALSE, TRUE)
	if(initiator.current_ticket)	//This is a bug
		stack_trace("Multiple ahelp current_tickets")
		initiator.current_ticket.AddInteraction("Ticket erroneously left open by code")
		initiator.current_ticket.Close()
	initiator.current_ticket = src

	TimeoutVerb()

	statclick = new(null, src)
	_interactions = list()

	if(is_bwoink)
		AddInteraction("<font color='blue'>[key_name_admin(usr)] PM'd [LinkedReplyName()]</font>")
		message_admins("<font color='blue'>Ticket [TicketHref("#[id]")] created</font>")
	else
		MessageNoRecipient(msg)

		//send it to chat bridge if nobody is on and tell us how many were on
		var/admin_number_present = send2bridge_adminless_only("**Ticket #[id]** created by **[key_name(initiator)]**", name, type = list(BRIDGE_ADMINALERT), mention = BRIDGE_MENTION_HERE)

		log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")

		world.send2bridge(
			type = list(BRIDGE_ADMINLOG),
			attachment_title = "**Ticket #[id]** created by **[key_name(initiator)]**",
			attachment_msg = name,
			attachment_color = BRIDGE_COLOR_ADMINLOG,
		)

		if(admin_number_present <= 0)
			to_chat(C, "<span class='notice'>No active admins are online[config.chat_bridge ? ", your adminhelp was sent to the admin chat" : ""].</span>")
			heard_by_no_admins = TRUE

	global.ahelp_tickets.active_tickets += src

/datum/admin_help/Destroy()
	RemoveActive()
	global.ahelp_tickets.closed_tickets -= src
	global.ahelp_tickets.resolved_tickets -= src
	return ..()

/datum/admin_help/proc/AddInteraction(formatted_message)
	if(heard_by_no_admins && usr && usr.ckey != initiator_ckey)
		heard_by_no_admins = FALSE
		world.send2bridge(
			type = list(BRIDGE_ADMINALERT, BRIDGE_ADMINLOG),
			attachment_title = "**Ticket #[id]** answered by **[key_name(usr)]**",
			attachment_color = BRIDGE_COLOR_ADMINALERT,
		)
	_interactions += "[time_stamp()]: [formatted_message]"

//Adds a cooldown to the user's ahelp verb.
/datum/admin_help/proc/TimeoutVerb()
	ahelp_tickets.ckey_cooldown_holder[initiator_ckey] = world.time + 2 MINUTES //2 minute cooldown of admin helps

//private
/datum/admin_help/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "\ref[src]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)
	if(state == AHELP_ACTIVE)
		. += ClosureLinks(ref_src)

//private
/datum/admin_help/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "\ref[src]"
	. = " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
	. += " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=icissue'>IC</A>)"
	. += " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"

//private
/datum/admin_help/proc/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "\ref[src]"
	return "<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

//private
/datum/admin_help/proc/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "\ref[src]"
	return "<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"

//message from the initiator without a target, all admins will see this
//won't bug irc
/datum/admin_help/proc/MessageNoRecipient(msg)
	var/ref_src = "\ref[src]"
	//Message to be sent to all admins
	var/admin_msg = "<span class='adminnotice'><span class='adminhelp'>Ticket [TicketHref("#[id]", ref_src)]</span><b>: [LinkedReplyName(ref_src)] [FullMonty(ref_src)]:</b> <span class='emojify linkify'>[msg]</span></span>"

	AddInteraction("<font color='red'>[LinkedReplyName(ref_src)]: [msg]</font>")

	//send this msg to all admins
	for(var/client/X in global.admins)
		X.mob.playsound_local(null, X.bwoink_sound, VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)
		window_flash(X)
		to_chat_admin_pm(X, admin_msg)

	//show it to the person adminhelping too
	to_chat_admin_pm(initiator, "<span class='adminnotice'>PM to-<b>Admins</b>: <span class='emojify linkify'>[msg]</span></span>")

//Reopen a closed ticket
/datum/admin_help/proc/Reopen()
	if(state == AHELP_ACTIVE)
		to_chat_admin_pm(usr, "<span class='warning'>This ticket is already open.</span>")
		return

	if(global.ahelp_tickets.CKey2ActiveTicket(initiator_ckey))
		to_chat_admin_pm(usr, "<span class='warning'>This user already has an active ticket, cannot reopen this one.</span>")
		return

	statclick = new(null, src)
	global.ahelp_tickets.active_tickets += src
	global.ahelp_tickets.closed_tickets -= src
	global.ahelp_tickets.resolved_tickets -= src
	state = AHELP_ACTIVE
	closed_at = null
	closed_at_server = null
	if(initiator)
		initiator.current_ticket = src

	AddInteraction("<font color='purple'>Reopened by [key_name_admin(usr)]</font>")
	var/msg = "<span class='adminhelp'>Ticket [TicketHref("#[id]")] reopened by [key_name_admin(usr)].</span>"
	message_admins(msg)
	log_admin_private(msg)
	world.send2bridge(
		type = list(BRIDGE_ADMINLOG),
		attachment_title = "**Ticket #[id]** reopened by **[key_name(usr)]**",
		attachment_color = BRIDGE_COLOR_ADMINLOG,
	)
	TicketPanel()	//can only be done from here, so refresh it

//private
/datum/admin_help/proc/RemoveActive()
	if(state != AHELP_ACTIVE)
		return
	closed_at = world.time
	closed_at_server = world.timeofday
	QDEL_NULL(statclick)
	global.ahelp_tickets.active_tickets -= src
	if(initiator && initiator.current_ticket == src)
		initiator.current_ticket = null

//Mark open ticket as closed/meme
/datum/admin_help/proc/Close(key_name = key_name_admin(usr), silent = FALSE)
	if(state != AHELP_ACTIVE)
		return
	RemoveActive()
	state = AHELP_CLOSED
	global.ahelp_tickets.ListInsert(src)
	AddInteraction("<font color='red'>Closed by [key_name].</font>")
	if(!silent)
		var/msg = "Ticket [TicketHref("#[id]")] closed by [key_name]."
		message_admins(msg)
		log_admin_private(msg)
		world.send2bridge(
			type = list(BRIDGE_ADMINLOG),
			attachment_title = "**Ticket #[id]** closed by **[key_name(usr)]**",
			attachment_color = BRIDGE_COLOR_ADMINLOG,
		)

//Mark open ticket as resolved/legitimate, returns ahelp verb
/datum/admin_help/proc/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	if(state != AHELP_ACTIVE)
		return
	RemoveActive()
	state = AHELP_RESOLVED
	global.ahelp_tickets.ListInsert(src)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(giveadminhelpverb), initiator_ckey), 50)

	AddInteraction("<font color='green'>Resolved by [key_name].</font>")
	to_chat(initiator, "<span class='adminhelp'>Your ticket has been resolved by an admin. The Adminhelp verb will be returned to you shortly.</span>")
	if(!silent)
		var/msg = "Ticket [TicketHref("#[id]")] resolved by [key_name]"
		message_admins(msg)
		log_admin_private(msg)
		world.send2bridge(
			type = list(BRIDGE_ADMINLOG),
			attachment_title = "**Ticket #[id]** resolved by **[key_name(usr)]**",
			attachment_color = BRIDGE_COLOR_ADMINLOG,
		)

//Close and return ahelp verb, use if ticket is incoherent
/datum/admin_help/proc/Reject(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	if(initiator)
		giveadminhelpverb(initiator.ckey)

		initiator.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

		var/msg = "<span class='warning' size='4'><b>- AdminHelp Rejected! -</b></span><br>" + \
			"<span class='warning'><b>Your admin help was rejected.</b> The adminhelp verb has been returned to you so that you may try again.</span><br>" + \
			"Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting."
	
		to_chat_admin_pm(initiator, msg)

	var/msg = "Ticket [TicketHref("#[id]")] rejected by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	world.send2bridge(
		type = list(BRIDGE_ADMINLOG),
		attachment_title = "**Ticket #[id]** rejected by **[key_name(usr)]**",
		attachment_color = BRIDGE_COLOR_ADMINLOG,
	)
	AddInteraction("Rejected by [key_name].")
	Close(silent = TRUE)

//Resolve ticket with IC Issue message
/datum/admin_help/proc/ICIssue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<span class='warning' size='4'><b>- AdminHelp marked as IC issue! -</b></span><br>" + \
		"<span class='warning'><b>Losing is part of the game!</b></span><br>" + \
		"<span class='warning'>Your character will frequently die, sometimes without even a possibility of avoiding it. Events will often be out of your control. No matter how good or prepared you are, sometimes you just lose.</span>"

	if(initiator)
		to_chat_admin_pm(initiator, msg)

	msg = "Ticket [TicketHref("#[id]")] marked as IC by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	world.send2bridge(
		type = list(BRIDGE_ADMINLOG),
		attachment_title = "**Ticket #[id]** marked as IC issue by **[key_name(usr)]**",
		attachment_color = BRIDGE_COLOR_ADMINLOG,
	)
	AddInteraction("Marked as IC issue by [key_name]")
	Resolve(silent = TRUE)

//Show the ticket panel
/datum/admin_help/proc/TicketPanel()
	var/list/dat = list("<title>Ticket #[id]</title>")
	var/ref_src = "\ref[src]"
	dat += "<h4>Admin Help Ticket #[id]: [LinkedReplyName(ref_src)]</h4>"
	dat += "<b>State: [ticket_status()]</b>"
	dat += "[TAB][TicketHref("Refresh", ref_src)][TAB][TicketHref("Re-Title", ref_src, "retitle")]"
	if(state != AHELP_ACTIVE)
		dat += "[TAB][TicketHref("Reopen", ref_src, "reopen")]"
	dat += "<br><br>Opened at: [time_stamp(wtime = opened_at_server)] (Approx [DisplayTimeText(world.time - opened_at)] ago)"
	if(closed_at && closed_at_server)
		dat += "<br>Closed at: [time_stamp(wtime = closed_at_server)] (Approx [DisplayTimeText(world.time - closed_at)] ago)"
	dat += "<br><br>"
	if(initiator)
		dat += "<b>Actions:</b> [FullMonty(ref_src)]<br>"
	else
		dat += "<b>DISCONNECTED</b>[TAB][ClosureLinks(ref_src)]<br>"
	dat += "<br><b>Log:</b><br><br>"
	for(var/I in _interactions)
		dat += "[I]<br>"

	// Append any tickets also opened by this user if relevant
	var/list/related_tickets = global.ahelp_tickets.TicketsByCKey(initiator_ckey)
	if (related_tickets.len > 1)
		dat += "<br/><b>Other Tickets by [initiator_ckey]</b><br/>"
		for (var/datum/admin_help/related_ticket in related_tickets)
			if (related_ticket.id == id)
				continue
			dat += "[related_ticket.TicketHref("#[related_ticket.id]")] ([related_ticket.ticket_status()]): [related_ticket.name]<br/>"

	var/datum/browser/popup = new(usr, "ahelp[id]", null, 620, 480, null, CSS_THEME_LIGHT)
	popup.set_content(dat.Join())
	popup.open()

/**
 * Renders the current status of the ticket into a displayable string
 */
/datum/admin_help/proc/ticket_status()
	switch(state)
		if(AHELP_ACTIVE)
			return "<font color='red'>OPEN</font>"
		if(AHELP_RESOLVED)
			return "<font color='green'>RESOLVED</font>"
		if(AHELP_CLOSED)
			return "CLOSED"
		else
			stack_trace("Invalid ticket state: [state]")
			return "INVALID, CALL A CODER"

/datum/admin_help/proc/Retitle()
	var/new_title = sanitize(input(usr, "Enter a title for the ticket", "Rename Ticket", name) as text|null)
	if(new_title)
		name = new_title
		//not saying the original name cause it could be a long ass message
		var/msg = "Ticket [TicketHref("#[id]")] titled [name] by [key_name_admin(usr)]"
		message_admins(msg)
		log_admin_private(msg)
	TicketPanel()	//we have to be here to do this

//Forwarded action from admin/Topic
/datum/admin_help/proc/Action(action)
	switch(action)
		if("ticket")
			TicketPanel()
		if("retitle")
			Retitle()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("icissue")
			ICIssue()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()

//
// TICKET STATCLICK
//

/obj/effect/statclick/ahelp
	var/datum/admin_help/ahelp_datum

/obj/effect/statclick/ahelp/atom_init(mapload, datum/admin_help/AH)
	ahelp_datum = AH
	. = ..()

/obj/effect/statclick/ahelp/update()
	return ..(ahelp_datum.name)

/obj/effect/statclick/ahelp/Click()
	ahelp_datum.TicketPanel()

/obj/effect/statclick/ahelp/Destroy()
	ahelp_datum = null
	return ..()

//
// CLIENT PROCS
//

/client/proc/is_ahelp_cooldown()
	var/ahelp_cooldown_timeleft = ahelp_tickets.ckey_cooldown_holder[ckey]
	if(ahelp_cooldown_timeleft && world.time < ahelp_cooldown_timeleft)
		to_chat_admin_pm(src, "<span class='notice'>You cannot use \"Adminhelp\" so often. Please wait another [round((ahelp_cooldown_timeleft - world.time) / 10, 1)] seconds.</span>")
		return TRUE
	else
		return FALSE

/proc/giveadminhelpverb(ckey)
	ahelp_tickets.ckey_cooldown_holder[ckey] = 0

/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"

	if(global.say_disabled)	//This is here to try to identify lag problems
		to_chat_admin_pm(src, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat_admin_pm(src, "<span class='warning'>Error: Admin-PM: You cannot send adminhelps (Muted).</span>")
		return

	if(is_ahelp_cooldown())
		return

	var/msg = sanitize(input(src, "Please describe your problem concisely and an admin will help as soon as they're able.", "Adminhelp contents") as message|null)
	if(!msg)
		return

	if(is_ahelp_cooldown())
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP))
		return

	if(current_ticket)
		if(tgui_alert(src, "You already have a ticket open. Is this for the same issue?",, list("Yes","No")) != "No")
			if(current_ticket)
				current_ticket.MessageNoRecipient(msg)
				current_ticket.TimeoutVerb()
				return
			else
				to_chat_admin_pm(src, "<span class='warning'>Ticket not found, creating new one...</span>")
		else
			current_ticket.AddInteraction("[key_name_admin(src)] opened a new ticket.")
			current_ticket.Close()

	new /datum/admin_help(msg, src, FALSE)

//
// LOGGING
//

//Use this proc when an admin takes action that may be related to an open ticket on what
//what can be a client, ckey, or mob
/proc/admin_ticket_log(what, message)
	var/client/C
	var/mob/Mob = what
	if(istype(Mob))
		C = Mob.client
	else
		C = what
	if(istype(C) && C.current_ticket)
		C.current_ticket.AddInteraction(message)
		return C.current_ticket
	if(istext(what))	//ckey
		var/datum/admin_help/AH = global.ahelp_tickets.CKey2ActiveTicket(what)
		if(AH)
			AH.AddInteraction(message)
			return AH

//
// HELPER PROCS
//

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in global.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X

/proc/get_admin_counts_formatted(requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)

	if(!length(adm["total"]))
		. = "No admins online"
	else if (!length(adm["present"]))
		. = "No active admins online; Stealthed\[[get_english_list(adm["stealth"])]\]; AFK\[[get_english_list(adm["afk"])]\]; Powerless\[[get_english_list(adm["noflags"])]\];"
	else
		. = "Active\[[get_english_list(adm["present"])]\]; Stealthed\[[get_english_list(adm["stealth"])]\]; AFK\[[get_english_list(adm["afk"])]\]; Powerless\[[get_english_list(adm["noflags"])]\];"

/proc/send2bridge_adminless_only(title, msg, requiredflags = R_BAN, type, mention)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "No admins online"
		else
			final = "All admins stealthed\[[get_english_list(stealthmins)]\], AFK\[[get_english_list(afkmins)]\], or lacks +BAN\[[get_english_list(powerlessmins)]\]! Total: [allmins.len] "

		world.send2bridge(
			type = type,
			attachment_title = title,
			attachment_msg = msg,
			attachment_color = BRIDGE_COLOR_ADMINALERT,
			attachment_footer = final,
			mention = mention,
		)
