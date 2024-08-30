/client
	var/datum/client_settings/settings

/client/verb/client_settings()
	set name = "Settings"
	set category = "OOC"

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
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClientSettings", "Client Settings")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/client_settings/tgui_data(mob/user, tab)
	if(tab)
		active_tab = tab
	var/list/data = list("active_tab" = active_tab, "settings" = list())

	var/client/C = user.client

	// todo: more static data can be moved to tgui_static
	switch(active_tab)
		if("keybinds")
			var/datum/pref/keybinds/P
			for(var/type in user.client.prefs.prefs_keybinds)
				P = user.client.prefs.prefs_keybinds[type]

				if(P.admins_only && !C.holder)
					continue
				if(P.supporters_only && !C.supporter)
					continue

				data["settings"] += list(list(
					"type" = "[P.type]", 
					"name" = P.name, 
					"category" = P.category,
					"description" = P.description,
					"value" = P.value, 
					"v_type" = P.value_type, 
					"v_parameters" = P.value_parameters,
					"default" = P.value == initial(P.value),
					"admins_only" = P.admins_only,
					"supporters_only" = P.supporters_only,
				))
		else
			var/datum/pref/player/P
			for(var/type in user.client.prefs.prefs_player)
				P = user.client.prefs.prefs_player[type]
				if(P.category != active_tab)
					continue

				if(P.admins_only && !C.holder)
					continue
				if(P.supporters_only && !C.supporter)
					continue

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

	return data

/datum/client_settings/tgui_static_data(mob/user)
	var/static/tabs = list(
		PREF_PLAYER_DISPLAY = "Экран",
		PREF_PLAYER_EFFECTS = "Эффекты",
		PREF_PLAYER_AUDIO = "Аудио",
		PREF_PLAYER_UI = "Интерфейс",
		PREF_PLAYER_CHAT = "Чат",
		PREF_PLAYER_GAME = "Игра",
		PREF_DOMAIN_KEYBINDS = "Управление",
	)

	var/static/pref_keybinds_ordered = list(
		PREF_KEYBINDS_CLIENT,
		PREF_KEYBINDS_COMMUNICATION,
		PREF_KEYBINDS_MOVEMENT,
		PREF_KEYBINDS_CARBON,
		PREF_KEYBINDS_HUMAN,
		PREF_KEYBINDS_ROBOT,
		PREF_KEYBINDS_EMOTE,
		PREF_KEYBINDS_MISC,
	)

	var/static/tabs_tips = list(
		PREF_PLAYER_EFFECTS = "Рекомендуется изменять настройки во время игры - так вы сможете сразу увидеть результат.",
		"keybinds" = "Некоторые клавиши или сочетания могут быть не доступны для назначения, проблема будет решена с Byond 516.",
	)

	var/list/data = list()
	data["tabs"] = tabs
	data["tabs_tips"] = tabs_tips
	data["keybinds_order"] = pref_keybinds_ordered
	return data

/datum/client_settings/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/client/C = ui.user.client

	if(action == "set_tab")
		active_tab = params["tab"]
		return TRUE

	var/datum/pref/pref_type = text2path(params["type"])
	if(!pref_type)
		return FALSE

	// first validate that we have permissions to change this pref
	if(initial(pref_type.admins_only) && !C.holder)
		return FALSE
	if(initial(pref_type.supporters_only) && !C.supporter)
		return FALSE

	if(ispath(pref_type, /datum/pref/player))
		if(ispath(pref_type, /datum/pref/player/meta))
			return

		switch(action)
			if("set_value")
				C.prefs.set_pref(pref_type, params["value"])
			if("modify_color_value")
				var/current_color = C.prefs.get_pref(pref_type)
				var/new_color = input(C, "Выберите новый цвет", "Выбор цвета", current_color) as color|null
				if(!new_color)
					return FALSE
				else
					C.prefs.set_pref(pref_type, new_color)
			if("reset_value")
				C.prefs.set_pref(pref_type, initial(pref_type.value))

	else if(ispath(pref_type, /datum/pref/keybinds))
		switch(action)
			if("set_value")
				C.prefs.set_keybind_pref(pref_type, params["value"])
			if("set_keybind_value")
				C.prefs.set_keybind_pref(pref_type, params["key"], params["index"], params["altMod"], params["ctrlMod"], params["shiftMod"])
			if("reset_value")
				C.prefs.set_keybind_pref(pref_type, initial(pref_type.value))

	return TRUE

/datum/client_settings/tgui_state(mob/user)
	return global.always_state
