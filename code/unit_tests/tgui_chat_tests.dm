#ifdef UNIT_TEST

/mob/tgui_chat_test_mob
	computer_id = "123456"
	var/address = "127.0.0.1"
	var/list/tgui_windows = list()
	var/datum/tgui_panel/tgui_panel
	var/tgui_cache_reloaded = FALSE

/datum/tgui_window/tgui_chat_test
	var/list/sent_messages = list()

/datum/tgui_window/tgui_chat_test/send_message(type, payload, force)
	if(!client)
		return
	var/message = TGUI_CREATE_MESSAGE(type, payload)
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	sent_messages += list(list("type" = type, "payload" = payload, "raw" = message))

/datum/tgui_window/tgui_chat_test/flush_message_queue()
	if(!client || !message_queue)
		return
	for(var/message in message_queue)
		sent_messages += list(list("raw" = message))
	message_queue = null

/datum/unit_test/tgui_panel_lifecycle_and_fallback
	name = "TGUI PANEL: browseroutput initialization, ping fallback, timeout guard, and old UI fallback."

/datum/unit_test/tgui_panel_lifecycle_and_fallback/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/tgui_chat_test_mob/mock_client = new(test_turf)
	var/datum/tgui_panel/panel = new(mock_client)
	mock_client.tgui_panel = panel

	if(!panel.window || panel.window.id != "browseroutput" || !panel.window.is_browser)
		fail("tgui_panel did not initialize browseroutput window with is_browser = TRUE.")
		qdel(panel)
		qdel(mock_client)
		return TRUE

	if(mock_client.tgui_windows["browseroutput"] != panel.window)
		fail("browseroutput window was not registered in tgui_windows.")
		qdel(panel)
		qdel(mock_client)
		return TRUE

	// Replace window with test double to inspect queued and flushed messages without a network client.
	var/datum/tgui_window/old_window = panel.window
	old_window.unsubscribe(panel)
	var/datum/tgui_window/tgui_chat_test/test_window = new(mock_client, "browseroutput", is_browser = TRUE)
	test_window.subscribe(panel, TYPE_PROC_REF(/datum/tgui_panel, on_message))
	panel.window = test_window

	if(panel.is_ready())
		fail("tgui_panel should not report ready before receiving ready or ping.")
		qdel(panel)
		qdel(old_window)
		qdel(mock_client)
		return TRUE

	// Messages sent while loading must be queued until ready/ping.
	test_window.send_message("chat/message", list(list("text" = "queued message")))
	if(!test_window.message_queue || length(test_window.message_queue) != 1 || test_window.sent_messages.len != 0)
		fail("Messages sent before ready were not queued on browseroutput window.")
		qdel(panel)
		qdel(old_window)
		qdel(mock_client)
		return TRUE

	// Verify ping fallback transitions window and panel to ready if initial ready was missed (#8104).
	test_window.on_message("ping", null, list("tgui" = "1", "window_id" = "browseroutput", "type" = "ping"))
	if(!test_window.is_ready() || !panel.ready_sent || !panel.is_ready())
		fail("tgui_panel did not become ready after receiving ping fallback.")
		qdel(panel)
		qdel(old_window)
		qdel(mock_client)
		return TRUE

	if(test_window.message_queue || test_window.sent_messages.len < 2)
		fail("browseroutput window did not flush queued messages and send config update on ping fallback.")
		qdel(panel)
		qdel(old_window)
		qdel(mock_client)
		return TRUE

	// Verify timeout callback does not reload or break an already-ready panel (#8104 / #12753).
	panel.on_initialize_timed_out()
	if(panel.broken || panel.auto_reloads != 0)
		fail("on_initialize_timed_out reloaded or broke an already-ready tgui_panel.")
		qdel(panel)
		qdel(old_window)
		qdel(mock_client)
		return TRUE

	// Verify switching to old UI marks panel not ready so SSchat falls back to SEND_TEXT (#12753).
	panel.broken = TRUE
	if(panel.is_ready())
		fail("tgui_panel reported ready while broken = TRUE (old UI fallback).")
		qdel(panel)
		qdel(old_window)
		qdel(mock_client)
		return TRUE

	pass("tgui_panel lifecycle, ping fallback, message queue flush, timeout guard, and old UI fallback verified.")
	qdel(panel)
	qdel(old_window)
	qdel(mock_client)
	return TRUE

#endif
