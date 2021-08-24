// todo:
// /datum/bridge_command/ticketslist
// /datum/bridge_command/ticketaction (close/open/etc., check TgsPm on tg)
// also need to work on PM answers, see belowe

/datum/bridge_command/pm
	name = "pm"
	desc = "(WiP)Send private message to player"
	format = "@Bot pm %ckey% %message%"
	example = "@Bot pm taukitty Hello! How are you?"
	position = 40

/datum/bridge_command/pm/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/message = sanitize(params["bridge_arg_2"])

	if(!ckey || !message)
		return

	var/client/target
	for(var/client/C in clients)
		if(C.ckey == ckey)
			target = C
			break

	if(!target)
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
			attachment_title = "Bridge: PM",
			attachment_msg = "<@![params["bridge_from_uid"]]> client [ckey] is offline!",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	if(!target.holder && !target.current_ticket)
		new /datum/admin_help(message, target, TRUE)

	if(!target.holder)
		to_chat(target, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")

	//todo: reply (priv_msg) currently works only with client
	//to_chat(target, "<font color='red'>Admin PM from-<b><a href='?priv_msg=[BRIDGE_FROM_SNIPPET_TEXT]'>[BRIDGE_FROM_SNIPPET_HTML]</a></b>: <span class='emojify linkify'>[message]</span></font>")
	to_chat(target, "<font color='red'>Remote admin PM from-<b>[BRIDGE_FROM_SNIPPET_HTML]</b>: <span class='emojify linkify'>[message]</span></font>")

	if(!target.holder)
		 // workaround because tickets needs clients to reply and it's not easy to change
		to_chat(target, "<font color='red'><i>Это удаленный ответ администратора, используйте F1 для ответа.</i></font>")
		giveadminhelpverb(target.ckey)

	admin_ticket_log(target, "<font color='blue'>PM From [BRIDGE_FROM_SNIPPET_TEXT]: [message]</font>")
	
	if(!target.holder)
		target.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

	log_admin_private("[BRIDGE_FROM_SNIPPET_TEXT]->[key_name(target)]: [message]")
	to_chat((global.admins-target), "<font color='blue'><B>PM: [BRIDGE_FROM_SNIPPET_TEXT]-&gt;[key_name(target, 1, 0)]:</B> <span class='emojify linkify'>[message]</span></font>" )

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
		attachment_title = "Bridge: PM",
		attachment_msg = "**<@![params["bridge_from_uid"]]>->[key_name(target)]:** [message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
