/datum/bridge_command/kick
	name = "kick"
	desc = "Kick player"
	format = "@Bot kick %ckey% %reason%"
	example = "@Bot kick taukitty For no reason"

/datum/bridge_command/kick/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/reason = sanitize(params["bridge_arg_2"])

	if(!ckey || !reason)
		return

	var/client/target
	for(var/client/C in clients)
		if(C.ckey == ckey)
			target = C
			break

	if(!target || target.holder)
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
			attachment_title = "Bridge: Kick",
			attachment_msg = "Kick command from <@![params["bridge_from_uid"]]> could not be executed: [target ? "admin can not be kicked" : "client not found"]",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	to_chat(target, "<span class='warning'>You have been kicked from the server by admin: [reason]</span>")

	log_admin("[BRIDGE_FROM_SNIPPET_TEXT] booted [key_name(target)] with reason: [reason].")
	message_admins("<span class='notice'>[BRIDGE_FROM_SNIPPET_HTML] booted [key_name_admin(target)] with reason: [reason].</span>")
	QDEL_IN(target, 2 SECONDS)

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
		attachment_title = "Bridge: Kick",
		attachment_msg = "Client **[target.ckey]** has been kicked by <@![params["bridge_from_uid"]]>",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/ert
	name = "ert"
	desc = "Call ERT, optionally set custom objective for the team"
	format = "@Bot ert %objective%"
	example = "@Bot ert"

/datum/bridge_command/ert/execute(list/params)
	var/objective = sanitize(params["bridge_arg_1"])

	var/message
	if(!SSticker || SSticker.current_state == 1)
		message = "<@![params["bridge_from_uid"]]> you can not call ERT if round has not started yet!"
	else if(trigger_armed_response_team(1, objective))
		if(objective)
			message = "<@![params["bridge_from_uid"]]> has called ERT, wish him good luck. ERT objective:\n[objective]"
			message_admins("[BRIDGE_FROM_SNIPPET_HTML] is dispatching an Emergency Response Team with objective: [objective].")
			log_admin("[BRIDGE_FROM_SNIPPET_TEXT] used Dispatch Response Team with objective: [objective].")
		else
			message = "<@![params["bridge_from_uid"]]> has called ERT, wish him good luck"
			message_admins("[BRIDGE_FROM_SNIPPET_HTML] is dispatching an Emergency Response Team.")
			log_admin("[BRIDGE_FROM_SNIPPET_TEXT] used Dispatch Response Team.")
	else
		message = "<@![params["bridge_from_uid"]]> ERT are already called"

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: ERT",
		attachment_msg = message,
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
