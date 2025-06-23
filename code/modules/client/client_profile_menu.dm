/datum/profile_settings

/datum/profile_settings/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProfileSettings")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/profile_settings/tgui_data(mob/user, tab)
	var/client/C = user.client

	var/list/data = list(
		"key" = C.key,
		"guest" = IsGuestKey(C.key),
		"password_authenticated" = C.password_authenticated,
		"hub_authenticated" = C.hub_authenticated,
		"guest_lobby_warning" = config.guest_mode == GUEST_LOBBY,
	)

	return data

/datum/profile_settings/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/client/C = ui.user.client

	switch(action)
		if("login")
			C.authenticate_with_password()
		if("logout")
			// this places token in logs, but anyway we now removing it
			var/token = params["token"]
			if(token)
				C.invalidate_access_tokens(token)

			if(tgui_alert(C, "Выйти со всех систем?", "Logout", list("Да", "Нет")) == "Да")
				C.invalidate_access_tokens()

			C.handle_storage_access_token(remove_token = TRUE)
			winset(C, null, "command=.reconnect")

		if("changepassword")
			C.set_password()

/datum/profile_settings/tgui_state(mob/user)
	return global.always_state
