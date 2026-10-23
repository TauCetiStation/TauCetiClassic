/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/ready_sent = FALSE
	var/initialized_at
	var/auto_reloads = 0

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput", is_browser = TRUE)
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	if(!client)
		return
	initialized_at = world.time
	broken = FALSE
	ready_sent = FALSE
	if(force)
		auto_reloads = 0
	// Perform a clean initialization
	window.initialize(
		inline_assets = list(
			get_asset_datum(/datum/asset/simple/tgui_panel),
		),
	)
	window.send_asset(get_asset_datum(/datum/asset/simple/fontawesome))
	// Other setup
	request_telemetry()
	addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	if(!client || broken || window.is_ready() || telemetry_analyzed_at)
		return
	if(auto_reloads < 3)
		auto_reloads++
		log_tgui(client, "tgui_panel timed out, reloading (attempt [auto_reloads]).", context = "tgui_panel/on_initialize_timed_out")
		initialize()
		return
	broken = TRUE
	SEND_TEXT(client, "<span class=\"userdanger\">Failed to load fancy chat, click <a href='byond://?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it.</span>")

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		ready_sent = TRUE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if(type == "ping" && !ready_sent)
		broken = FALSE
		ready_sent = TRUE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
	if(type == "telemetry")
		auto_reloads = 0
		analyze_telemetry(payload)
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")
