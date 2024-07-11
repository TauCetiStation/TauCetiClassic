/client
	var/datum/client_settings/settings

/client/verb/client_settings()
	set name = "Settings"
	set category = "Preferences"

	open_settings_menu()

/client/proc/open_settings_menu(tab)
	if(!prefs_ready)
		to_chat(usr, "Need more time for initialization!")
		return

	if(!settings)
		settings = new /datum/client_settings(src)
	settings.tgui_interact(usr, tab)

/datum/client_settings
	var/active_tab = PREF_PLAYER_DISPLAY

/datum/client_settings/tgui_interact(mob/user, datum/tgui/ui)
	world.log << "tgui_interact"
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		world.log << "open"
		ui = new(user, src, "ClientSettings", "Client Settings")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/client_settings/tgui_data(mob/user, tab)
	if(tab)
		active_tab = tab
	var/list/data = list("active_tab" = active_tab, "settings" = list())

	//if(tab == PREF_DOMAIN_KEYBINDS)

	var/datum/pref/player/P
	for(var/type in user.client.prefs.preferences_list)
		P = user.client.prefs.preferences_list[type]
		if(P.category != active_tab)
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
	//world.log << json_encode(data)


	return data

/datum/client_settings/tgui_static_data(mob/user)
	var/static/tabs = list(
		PREF_PLAYER_DISPLAY = "Экран",
		PREF_PLAYER_EFFECTS = "Эффекты",
		PREF_PLAYER_AUDIO = "Аудио",
		PREF_PLAYER_UI = "Интерфейс",
		PREF_PLAYER_CHAT = "Чат",
		PREF_PLAYER_GAME = "Игра",
		PREF_PLAYER_KEYBINDS = "Управление",
	)

	var/static/tabs_tips = list(
		PREF_PLAYER_EFFECTS = "Рекомендуется изменять настройки во время игры - так вы сможете сразу увидеть результат.",
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

	var/datum/pref/player/pref_type
	if(params["type"]) // first validate that we have permissions to change this pref
		pref_type = text2path(params["type"])
		if(!pref_type || !ispath(pref_type, /datum/pref/player))
			return
		if(initial(pref_type.admins_only) && !C.holder)
			return
		if(initial(pref_type.supporters_only) && !C.supporter)
			return

	switch(action)
		if("set_value")
			C.prefs.set_pref(pref_type, params["value"])
		if("set_tab")
			active_tab = params["tab"]
		if("modify_color_value")
			var/current_color = C.prefs.get_pref(pref_type)
			var/new_color = input(C, "Выберите новый цвет", "Выбор цвета", current_color) as color|null
			if(!new_color)
				return FALSE
			else
				C.prefs.set_pref(pref_type, new_color)
		if("reset_value")
			C.prefs.set_pref(pref_type, initial(pref_type.value))

	return TRUE

/datum/client_settings/tgui_state(mob/user)
	return global.always_state //global.admin_state
