//toggles

/client/verb/toggle_be_role(role in special_roles)
	set name = "Toggle SpecialRole Candidacy"
	set category = "Preferences"
	set desc = "Toggles which special roles you would like to be a candidate for, during events."
	var/role_type = role
	if(!role_type)	return
	if(role_type in prefs.be_role)
		prefs.be_role -= role_type
	else
		prefs.be_role += role_type
	prefs.save_preferences()
	to_chat(src, "You will [(role_type in prefs.be_role) ? "now" : "no longer"] be considered for [role] events (where possible).")
	feedback_add_details("admin_verb","TBeSpecial") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ignored_role()
	set name = "Toggle Ignore Roles"
	set category = "Preferences"
	set desc = "Toggles ignore questions"

	var/role = input(usr, "Ignored Qustions for Roles in current Round:") as null|anything in prefs.ignore_question
	if(!role)
		return
	prefs.ignore_question -= role
	to_chat(src, "You will receive requests for \"[role]\" again")
	feedback_add_details("admin_verb","TBeSpecialIgnore") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_hotkeys_mode()
	set name = "Toggle Hotkeys Mode"
	set category = "Preferences"

	prefs.toggle_hotkeys_mode()
	if(prefs.hotkeys)
		to_chat(src, "Режим хоткеев переключен: при клике в окно игры фокус будет переключен на окно игры")
	else
		to_chat(src, "Режим хоткеев переключен: при клике в окно игры фокус останется на чате.")
	feedback_add_details("admin_verb", "thm")

/client/verb/edit_emote_panel()
	set name = "Edit Emote Panel"
	set category = "Preferences"

	if(!emote_panel_editor)
		emote_panel_editor = new /datum/emote_panel_editor(src)
	emote_panel_editor.tgui_interact(usr)

