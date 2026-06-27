
 // HTML structure matches tgstation tgchat CSS (fieldset + boxed_message + chat_alert_*)

// Generic boxed message
/proc/boxed_message(content)
	return "<div class='boxed_message'>[content]</div>"

/proc/custom_boxed_message(classes, content)
	return "<div class='boxed_message [classes]'>[content]</div>"

/proc/fieldset_block(title, content, classes = "")
	return "<fieldset class='fieldset [classes]'><legend class='fieldset_legend'>[title]</legend><div class='fieldset_body'>[content]</div></fieldset>"

/proc/separator_hr(content)
	return "<div class='separator'>[content]</div>"

/proc/create_announcement_div(message, color = "default")
	return "<div class='chat_alert_[color]'>[message]</div>"

/proc/create_ooc_announcement_div(message)
	return "<div class='ooc_alert'>[message]</div>"

/proc/major_announcement_block(title, subtitle, content, color = "default")
	var/list/parts = list()
	if(title)
		parts += "<span class='major_announcement_title'>[title]</span>"
	if(subtitle)
		parts += "<span class='subheader_announcement_text'>[subtitle]</span>"
	if(content)
		parts += "<span class='major_announcement_text'>[content]</span>"
	return create_announcement_div(jointext(parts, ""), color)

// Sends a global admin announcement in TG OOC-alert style
/proc/send_ooc_announcement(text, title = "", sender_override = "Server Admin Announcement")
	var/list/parts = list()
	parts += "<span class='major_announcement_title'>[sender_override]</span>"
	if(title)
		parts += "<span class='subheader_announcement_text'>[title]</span>"
	parts += "<span class='ooc_announcement_text'>[text]</span>"
	to_chat(world, create_ooc_announcement_div(jointext(parts, "")))

// Admin PM received by a player — red boxed fieldset (tg receive_ahelp)
/client/proc/receive_ahelp(reply_to, message, span_class = "adminsay")
	to_chat_admin_pm(src, fieldset_block(
		"<span class='adminhelp'>Administrator private message</span>",
		"<span class='[span_class]'>Admin PM from <b>[reply_to]</b></span><br><br><span class='[span_class]'>[message]</span><br><br><i class='adminsay'>Нажмите на имя администратора для ответа.</i>",
		"red_box"))

// Colored boxed message shortcuts

/proc/red_boxed_message(content)
	return custom_boxed_message("red_box", content)

/proc/green_boxed_message(content)
	return custom_boxed_message("green_box", content)

/proc/blue_boxed_message(content)
	return custom_boxed_message("blue_box", content)

/proc/purple_boxed_message(content)
	return custom_boxed_message("purple_box", content)

/proc/orange_boxed_message(content)
	return custom_boxed_message("orange_box", content)
