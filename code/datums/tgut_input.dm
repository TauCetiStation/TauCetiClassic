/*
 * Creates an easy-to-edit input on TGUI
 * To use this framework, you just need to define the necessary onentern() function
 * And create an object in the right place.
 * Example: var/datum/input/ic/IC = inputs[IC_INPUT]
 *          IC.interact()
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
	tgui_interact(speaker)

/datum/input/proc/oninput(message)
	SHOULD_CALL_PARENT(TRUE)
	src.message = message

/datum/input/proc/onenter(message)
	SHOULD_CALL_PARENT(TRUE)
	src.message = message
	tgui_window.close()

/datum/input/proc/cancel()
	SHOULD_CALL_PARENT(TRUE)
	src.message = ""
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
			to_chat(world, "input - [params["message"]]")
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

/datum/input/ic/onenter(message)
	..()
	SEND_SIGNAL(speaker, COMSIG_MOB_SAID, src.message)

/datum/input/me
	title = ME_INPUT
	place_holder = "Enter a emotion"
