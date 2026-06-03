/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "OOC"
	var/action
	log_tgui(src, "Started fixing.", context = "verb/fix_tgui_panel")

	nuke_chat()

	// Failed to fix, using tg_alert as fallback
	action = tgui_alert(src, "Did that work?", "", list("Yes", "No, switch to old ui"))
	if (action == "No, switch to old ui")
		winset(src, "legacy_output_selector", "left=output_legacy")
		log_tgui(src, "Failed to fix.", context = "verb/fix_tgui_panel")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "legacy_output_selector", "left=output_legacy")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing",
			context = "verb/fix_tgui_panel")
		tgui_panel = new(src)
	tgui_panel.initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "legacy_output_selector", "left=output_browser")


/client/verb/refresh_tgui()
	set name = "Refresh TGUI"
	set category = "OOC"

	for(var/window_id in tgui_windows)
		var/datum/tgui_window/window = tgui_windows[window_id]
		window.reinitialize()

/mob/verb/reset_ui_positions_for_mob()
	set name = "Reset TGUI Positions"
	set category = "OOC"
	SStgui.reset_ui_position(src)

/client/verb/fix_ui()
	set name = "Close all UIs (Fix UI)"
	set desc = "Closes all opened NanoUI/TGUI and reloads your TGUI/NanoUI assets if they are not working"
	set category = "OOC"

	if(last_ui_resource_send > world.time)
		to_chat(usr, "<span class='warning'>You requested your TGUI/NanoUI resource files too quickly. This button reloads your NanoUI and TGUI/NanoUI resources. If you have any open UIs this may break them. Please try again in [(last_ui_resource_send - world.time)/10] seconds.</span>")
		return
	last_ui_resource_send = world.time + 60 SECONDS

	// Close all NanoUI/TGUI windows
	nanomanager.close_user_uis(usr)
	SStgui.close_user_uis(usr)

	// Clear the user's cache so they get resent.
	// This is not fully clearing their BYOND cache, just their assets sent from the server this round
	sent_assets = list()

	to_chat(src, "<span class='notice'>UI resource files resent. If you are still having issues, please try manually clearing your BYOND cache.</span>")
