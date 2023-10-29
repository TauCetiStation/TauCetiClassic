/client
	var/datum/emote_panel_editor

/datum/emote_panel_editor
	var/list/custom_emote_panel
	var/datum/preferences/prefs

/datum/emote_panel_editor/New(client/user)
	src.prefs = user.prefs
	src.custom_emote_panel = prefs.custom_emote_panel

/datum/emote_panel_editor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmotePanelEditor", "Настройки")
		ui.open()

/datum/emote_panel_editor/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("switchEmote")
			var/emote = params["emote"]

			if(!(emote in global.emotes_for_emote_panel))
				return

			if(emote in custom_emote_panel)
				custom_emote_panel -= emote
			else
				custom_emote_panel += emote

			prefs.save_preferences()

	return TRUE

/datum/emote_panel_editor/tgui_state(mob/user)
	return global.always_state

/datum/emote_panel_editor/tgui_data(mob/user)
	var/list/data = list()

	data["customEmotes"] = custom_emote_panel
	data["allHumanEmotes"] = global.emotes_for_emote_panel

	return data
