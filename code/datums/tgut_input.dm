/*
 * Creates an easy-to-edit input on TGUI.
 * To use it, you must send a signal to the talking mob.
 * For example, find "say_input()" and "/datum/input/ic"
*/

#define IC_INPUT "IC"
#define OOC_INPUT "OOC"
#define ME_INPUT "Me"

/datum/input
	// Title of window
	var/title
	// Current message
	var/message = ""
	// Gray text written on the input, but it is not a message
	var/place_holder = ""
	// Created window
	var/datum/tgui/tgui_window
	// The mob who called this window
	var/mob/speaker

/datum/input/New(mob/user)
	speaker = user

/datum/input/Destroy()
	speaker = null
	tgui_window = null
	return ..()

/datum/input/proc/interact()
	SHOULD_CALL_PARENT(TRUE)
	message = ""
	tgui_interact(speaker)

/datum/input/proc/oninput(message)
	SHOULD_CALL_PARENT(TRUE)
	if(message)
		src.message = message

/datum/input/proc/onenter(message)
	SHOULD_CALL_PARENT(TRUE)
	if(message)
		src.message = message
	// Focus on game-window
	winset(speaker, null, "mapwindow.map.focus=true")
	tgui_window.close()

/datum/input/proc/cancel()
	SHOULD_CALL_PARENT(TRUE)
	src.message = ""
	winset(speaker, null, "mapwindow.map.focus=true")
	tgui_window.close()

/datum/input/tgui_host(mob/user)
	return user

/datum/input/tgui_status()
	return UI_INTERACTIVE

/datum/input/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SSInput", title)
		tgui_window = ui
		ui.open()

/datum/input/tgui_data(mob/user)
	var/list/data = list()
	data["new_placeholder"] = place_holder
	data["title"] = title
	data["possible_prefix"] = global.department_radio_keys
	return data

/datum/input/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("oninput")
			oninput(params["message"])
		if("onenter")
			to_chat(world, "enter - [params["message"]]")
			onenter(params["message"])
		if("cancel")
			to_chat(world, "cancel - [params["message"]]")
			cancel()

/datum/input/ooc
	title = OOC_INPUT
	place_holder = "Enter a message"

/datum/input/ic
	title = IC_INPUT
	place_holder = "Enter a message"

/datum/input/ic/interact()
	..()
	speaker.set_typing_indicator(TRUE)

/datum/input/ic/onenter(message)
	..()
	SEND_SIGNAL(speaker, COMSIG_MOB_SAID, src.message)
	speaker.set_typing_indicator(FALSE)

/datum/input/ic/cancel()
	..()
	speaker.set_typing_indicator(FALSE)

/datum/input/me
	title = ME_INPUT
	place_holder = "Enter a emotion"
