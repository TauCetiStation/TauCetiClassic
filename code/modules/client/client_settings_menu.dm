/client
	var/datum/client_settings/settings

/client/verb/client_settings()
	set name = "Settings"
	set category = "Preferences"

	if(!prefs_ready)
		to_chat(usr, "Need more time for initialization!")
		return

	if(!settings)
		settings = new /datum/client_settings(src)
	settings.tgui_interact(usr)

/datum/client_settings
	var/tab = PREF_PLAYER_UI // change to default

/datum/client_settings/tgui_interact(mob/user, datum/tgui/ui)
	world.log << "tgui_interact"
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		world.log << "open"
		ui = new(user, src, "ClientSettings", "Client Settings")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/client_settings/tgui_data(mob/user)
	var/list/data = list("active_tab" = tab, "settings" = list())

	//if(tab == PREF_DOMAIN_KEYBINDS)

	var/datum/pref/player/P
	for(var/type in user.client.prefs.player_settings)
		P = user.client.prefs.player_settings[type]
		if(P.category != tab)
			continue

		// todo: more static data can be moved to tgui_static
		data["settings"] += list(list(
			"type" = "[P.type]", 
			"name" = P.name, 
			"description" = P.description, 
			"value" = P.value, 
			"v_type" = P.value_type, 
			"v_parameters" = P.value_parameters,
			"default" = P.value == initial(P.value),
			"admins_only" = P.admins_only,
			"supporters_only" = P.supporters_only,
		))

	world.log << "CS: tgui_data [length(data["settings"])]"
	world.log << json_encode(data)


	return data

/datum/client_settings/tgui_static_data(mob/user)
	var/static/tabs = list(
		PREF_PLAYER_UI = "Интерфейс",
		PREF_PLAYER_GRAPHICS = "Графика",
		PREF_PLAYER_AUDIO = "Аудио",
		PREF_PLAYER_CHAT = "Чат",
		PREF_PLAYER_GAME = "Игра",
		PREF_PLAYER_KEYBINDS = "Управление",
	)

	var/static/tabs_tips = list(
		PREF_PLAYER_GRAPHICS = "Рекомендуется изменять настройки во время игры - так вы сможете сразу увидить результат.",
	)

	var/list/data = list()
	data["tabs"] = tabs
	data["tabs_tips"] = tabs_tips
	return data

/datum/client_settings/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/client/C = ui.user.client

	world.log << "TGUI ACT [action]: [json_encode(params)]"

	switch(action)
		if("set_value")
			C.prefs.set_pref(text2path(params["type"]), params["value"])
		if("set_tab")
			tab = params["tab"]
		if("modify_color_value")
			var/current_color = C.prefs.get_pref(text2path(params["type"]))
			var/new_color = input(C, "Выберите новый цвет", "Colopick", current_color) as color|null
			if(!new_color)
				return FALSE
			else
				C.prefs.set_pref(text2path(params["type"]), new_color)
		if("reset_value")
			var/datum/pref/player/P = text2path(params["type"])
			C.prefs.set_pref(text2path(params["type"]), initial(P.value))

	return TRUE

/datum/client_settings/tgui_state(mob/user)
	return global.always_state //global.admin_state
