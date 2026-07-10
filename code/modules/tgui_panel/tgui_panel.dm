/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

#define TGUI_PANEL_MAX_INITIALIZATION_RETRIES 3
#define TGUI_PANEL_INITIALIZATION_TIMEOUT 10 SECONDS
#define TGUI_PANEL_HEALTHCHECK_TIMEOUT 5 SECONDS
#define TGUI_PANEL_MAX_PENDING_CHAT_MESSAGES 200

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	var/initialization_attempt = 0
	var/initialization_ready_attempt = 0
	var/initialization_request = 0
	var/initialization_retries = 0
	var/initialization_timer_id
	var/healthcheck_id = 0
	var/healthcheck_timer_id
	var/list/pending_chat_messages

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	initialization_request++
	clear_initialization_timer()
	clear_healthcheck_timer()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken \
		&& initialization_ready_attempt == initialization_attempt \
		&& !healthcheck_timer_id \
		&& window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	initialization_request++
	var/current_request = initialization_request
	clear_initialization_timer()
	healthcheck_id++
	clear_healthcheck_timer()
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	if(!client || current_request != initialization_request)
		return
	if(!force && is_ready())
		return
	if(force)
		initialization_retries = 0
	start_initialization()

/**
 * private
 *
 * Starts a new initialization attempt without the client-constructor delay.
 */
/datum/tgui_panel/proc/start_initialization()
	clear_initialization_timer()
	broken = FALSE
	initialization_attempt++
	var/current_attempt = initialization_attempt
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(
		inline_assets = list(
			get_asset_datum(/datum/asset/simple/tgui_panel),
		),
		inline_html = "<meta id=\"tgui-panel-attempt\" content=\"[current_attempt]\">",
	)
	initialization_timer_id = addtimer(
		CALLBACK(src, PROC_REF(on_initialize_timed_out), current_attempt),
		TGUI_PANEL_INITIALIZATION_TIMEOUT,
		TIMER_STOPPABLE,
	)

/**
 * private
 *
 * Cancels the timeout belonging to the active initialization attempt.
 */
/datum/tgui_panel/proc/clear_initialization_timer()
	if(!initialization_timer_id)
		return
	deltimer(initialization_timer_id)
	initialization_timer_id = null

/**
 * private
 *
 * Cancels the active panel healthcheck timeout.
 */
/datum/tgui_panel/proc/clear_healthcheck_timer()
	if(!healthcheck_timer_id)
		return
	deltimer(healthcheck_timer_id)
	healthcheck_timer_id = null

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out(attempt)
	if(!client || attempt != initialization_attempt || initialization_ready_attempt == attempt)
		return
	initialization_timer_id = null

	if(initialization_retries < TGUI_PANEL_MAX_INITIALIZATION_RETRIES)
		initialization_retries++
		log_tgui(client,
			"Fancy chat initialization timed out, retrying ([initialization_retries]/[TGUI_PANEL_MAX_INITIALIZATION_RETRIES]).",
			context = "tgui_panel/initialize")
		winset(client, "legacy_output_selector", "left=output_legacy")
		start_initialization()
		return

	broken = TRUE
	log_tgui(client,
		"Fancy chat initialization failed after [initialization_retries] retries.",
		context = "tgui_panel/initialize")
	window.message_queue = null
	pending_chat_messages = null
	winset(client, "legacy_output_selector", "left=output_legacy")
	SEND_TEXT(client, "<span class=\"userdanger\">Failed to load fancy chat, click <a href='byond://?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it.</span>")

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		return TRUE
	if(type == "panel/booted")
		if(!islist(payload))
			return TRUE
		var/booted_attempt = payload["attempt"]
		if(!isnum(booted_attempt) || booted_attempt != initialization_attempt)
			return TRUE
		initialization_ready_attempt = 0
		window.send_asset(get_asset_datum(/datum/asset/simple/fontawesome))
		request_telemetry()
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
	if(type == "panel/ready")
		if(!islist(payload))
			return TRUE
		var/ready_attempt = payload["attempt"]
		if(!isnum(ready_attempt) || ready_attempt != initialization_attempt)
			return TRUE
		initialization_ready_attempt = ready_attempt
		broken = FALSE
		initialization_retries = 0
		clear_initialization_timer()
		healthcheck_id++
		clear_healthcheck_timer()
		flush_pending_chat()
		return TRUE
	if(type == "panel/healthy")
		if(!islist(payload))
			return TRUE
		if(payload["id"] != healthcheck_id || payload["attempt"] != initialization_attempt)
			return TRUE
		clear_healthcheck_timer()
		flush_pending_chat()
		return TRUE
	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE

/**
 * public
 *
 * Sends a chat batch to TGUI when ready, or caches it while using legacy output.
 */
/datum/tgui_panel/proc/send_chat(payload)
	if(!client)
		return
	if(is_ready())
		window.send_message("chat/message", payload)
		return
	for(var/message in payload)
		SEND_TEXT(client, message_to_html(message))
		if(!broken)
			queue_pending_chat(message)

/**
 * public
 *
 * Sends an immediate chat message using the same recovery queue as batches.
 */
/datum/tgui_panel/proc/send_chat_immediate(message, message_blob, message_html)
	if(!client)
		return
	SEND_TEXT(client, message_html)
	if(is_ready())
		window.send_raw_message(message_blob)
		return
	if(!broken)
		queue_pending_chat(message)

/**
 * private
 *
 * Keeps a bounded chat history for replay after the panel recovers.
 */
/datum/tgui_panel/proc/queue_pending_chat(message)
	LAZYADD(pending_chat_messages, list(message))
	if(length(pending_chat_messages) > TGUI_PANEL_MAX_PENDING_CHAT_MESSAGES)
		pending_chat_messages.Cut(1, length(pending_chat_messages) - TGUI_PANEL_MAX_PENDING_CHAT_MESSAGES + 1)

/**
 * private
 *
 * Replays chat captured while the panel was booting or being probed.
 */
/datum/tgui_panel/proc/flush_pending_chat()
	if(!length(pending_chat_messages) || !is_ready())
		return
	window.send_message("chat/message", pending_chat_messages)
	pending_chat_messages = null

/**
 * public
 *
 * Verifies that the panel bundle still processes messages at round start.
 */
/datum/tgui_panel/proc/check_health()
	if(!client)
		return
	if(!is_ready())
		initialize(force = TRUE)
		return
	healthcheck_id++
	var/current_healthcheck = healthcheck_id
	clear_healthcheck_timer()
	window.send_message("panel/healthcheck", list(
		"id" = current_healthcheck,
		"attempt" = initialization_attempt,
	))
	healthcheck_timer_id = addtimer(
		CALLBACK(src, PROC_REF(on_healthcheck_timed_out), current_healthcheck, initialization_attempt),
		TGUI_PANEL_HEALTHCHECK_TIMEOUT,
		TIMER_STOPPABLE,
	)

/**
 * private
 *
 * Starts recovery when the panel bundle does not answer a healthcheck.
 */
/datum/tgui_panel/proc/on_healthcheck_timed_out(healthcheck, attempt)
	if(!client || healthcheck != healthcheck_id || attempt != initialization_attempt)
		return
	healthcheck_timer_id = null
	broken = TRUE
	log_tgui(client, "Fancy chat failed its round-start healthcheck.", context = "tgui_panel/check_health")
	winset(client, "legacy_output_selector", "left=output_legacy")
	initialize(force = TRUE)

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	if(is_ready())
		window.send_message("roundrestart")

#undef TGUI_PANEL_MAX_INITIALIZATION_RETRIES
#undef TGUI_PANEL_INITIALIZATION_TIMEOUT
#undef TGUI_PANEL_HEALTHCHECK_TIMEOUT
#undef TGUI_PANEL_MAX_PENDING_CHAT_MESSAGES
