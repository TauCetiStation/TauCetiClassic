/client
	var/datum/emote_panel_editor

/datum/emote_panel_editor
	var/list/enabled_emotes
	var/datum/preferences/prefs

/datum/emote_panel_editor/New(client/user)
	src.prefs = user.prefs
	src.enabled_emotes = prefs.enabled_emotes_emote_panel

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

			if(emote in enabled_emotes)
				enabled_emotes -= emote
			else
				enabled_emotes += emote

			var/list/disabled_emotes = global.emotes_for_emote_panel - enabled_emotes
			prefs.set_pref(/datum/pref/player/meta/disabled_emotes_emote_panel, disabled_emotes)

	return TRUE

/datum/emote_panel_editor/tgui_state(mob/user)
	return global.always_state

/datum/emote_panel_editor/tgui_data(mob/user)
	var/list/data = list()

	data["customEmotes"] = enabled_emotes
	data["allHumanEmotes"] = global.emotes_for_emote_panel

	return data
