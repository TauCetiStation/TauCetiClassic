/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

SUBSYSTEM_DEF(chat)
	name = "Chat"
	init_order = SS_INIT_CHAT
	wait = SS_WAIT_CHAT
	priority = SS_PRIORITY_CHAT
	flags = SS_TICKER | SS_SHOW_IN_MC_TAB

	var/list/payload_by_client = list()

/datum/controller/subsystem/chat/fire()
	for(var/client/client as anything in payload_by_client)
		var/payload = payload_by_client[client]
		payload_by_client -= client
		if(client)
			if(client.tgui_panel)
				client.tgui_panel.send_chat(payload)
			else
				for(var/message in payload)
					SEND_TEXT(client, message_to_html(message))
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/chat/proc/queue(target, message)
	SSdemo.write_chat(target, message_to_html(message))

	if(islist(target))
		for(var/_target in target)
			var/client/client = CLIENT_FROM_VAR(_target)
			if(client)
				LAZYADD(payload_by_client[client], list(message))
		return
	var/client/client = CLIENT_FROM_VAR(target)
	if(client)
		LAZYADD(payload_by_client[client], list(message))
