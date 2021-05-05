SUBSYSTEM_DEF(chat)
	name = "Chat"
	init_order = SS_INIT_CHAT
	wait = SS_WAIT_CHAT
	priority = SS_PRIORITY_CHAT
	flags = SS_TICKER|SS_NO_INIT

	var/list/payload = list()

/datum/controller/subsystem/chat/fire()
	for(var/i in payload)
		var/client/C = i
		C << output(payload[C], "browseroutput:output")
		payload -= C

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/chat/proc/queue(target, message, handle_whitespace = TRUE)
	if(!target || !message)
		return

	if(!istext(message))
		stack_trace("to_chat called with invalid input type")
		return

	if(target == world)
		target = clients

	//Some macros remain in the string even after parsing and fuck up the eventual output
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", ENTITY_TAB)

	var/encoded = url_encode(message)

	SSdemo.write_chat(target, message)

	if(islist(target))
		for(var/I in target)
			var/client/C = CLIENT_FROM_VAR(I) //Grab us a client if possible

			if(!C?.chatOutput || C.chatOutput.broken) //A player who hasn't updated his skin file.
				continue

			if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			if(payload[C])
				payload[C] += "<br>"
			payload[C] += encoded
	else
		var/client/C = CLIENT_FROM_VAR(target) //Grab us a client if possible

		if(!C?.chatOutput || C.chatOutput.broken) //A player who hasn't updated his skin file.
			return

		if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		if(payload[C])
			payload[C] += "<br>"
		payload[C] += encoded
