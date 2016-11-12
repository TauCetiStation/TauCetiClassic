/proc/send2slack(channel, msg, attachment_msg, name, icon)
	if(!config.use_slack_bot || !config.slack_team || !channel || !msg)
		return 0

	//more info here: https://api.slack.com/docs/formatting
	msg = sanitize_slack(msg)

	var/script_args = "\"[channel]\" \"[msg]\""

	if(attachment_msg)
		script_args += " --attachment_message \"[sanitize_slack(attachment_msg)]\""
	if(name)
		script_args += " --name \"[sanitize_slack(name)]\""
	if(icon)
		script_args += " --icon \"[sanitize_slack(icon)]\""

	//required positional args: channel, text
	//optional: --attachment_message TEXT, --name NAME, --icon EMOJI
	ext_python("slackbot_message.py", script_args)

/proc/send2slack_service(msg)
	if(!msg)
		return
	var/server_name = config.server_name ? config.server_name : "Noname server"
	msg = server_name + " reports: " + msg

	send2slack("service", msg)

/proc/send2slack_admincall(msg, amsg)
	if(!amsg)
		return

	/* to prevent abuse @mentions */
	amsg = replacetext(amsg, "@channel", "_channel")
	amsg = replacetext(amsg, "@group", "_group")
	amsg = replacetext(amsg, "@everyone", "_everyone")

	var/server_name = config.server_name ? config.server_name : "Noname server"
	var/name = server_name + " player report"

	send2slack("modcomm", msg, amsg, name, ":scream_cat:")

/proc/send2slack_custommsg(msg, amsg, icon)
	if(!amsg)
		return

	/* no point in any mentions here */
	amsg = replacetext(amsg, "@", "_")

	var/regex/break_line = new("<BR>", "g")
	var/regex/clear_tags = new("<.*?>", "g")

	amsg = break_line.Replace(amsg, "\n")
	amsg = clear_tags.Replace(amsg, "")

	var/server_name = config.server_name ? config.server_name : "Noname server"
	var/name = server_name + " player message"

	send2slack("modcomm", msg, amsg, name, icon)

/proc/send2slack_logs(msg, amsg, type)
	if(!msg || !amsg || !type)
		return

	/* no point in any mentions here */
	amsg = replacetext(amsg, "@", "_")

	var/server_name = config.server_name ? config.server_name : "Noname server"
	var/name = server_name + " [type]"
	send2slack("logcomm", msg, amsg, name)

/proc/slack_startup()
	send2slack_service("server starting up")

/proc/slack_roundstart()
	send2slack_service("round is started, gamemode - [master_mode]")

/proc/slack_roundend()
	send2slack_service("round is over")
