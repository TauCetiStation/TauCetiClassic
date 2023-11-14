/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Maximum number of connection records allowed to analyze.
 * Should match the value set in the browser.
 */
#define TGUI_TELEMETRY_MAX_CONNECTIONS 5

/**
 * Maximum time allocated for sending a telemetry packet.
 */
#define TGUI_TELEMETRY_RESPONSE_WINDOW 30 SECONDS

/// Time of telemetry request
/datum/tgui_panel/var/telemetry_requested_at
/// Time of telemetry analysis completion
/datum/tgui_panel/var/telemetry_analyzed_at
/// List of previous client connections
/datum/tgui_panel/var/list/telemetry_connections

/**
 * private
 *
 * Requests some telemetry from the client.
 */
/datum/tgui_panel/proc/request_telemetry()
	telemetry_requested_at = world.time
	telemetry_analyzed_at = null
	window.send_message("telemetry/request", list(
		"limits" = list(
			"connections" = TGUI_TELEMETRY_MAX_CONNECTIONS,
		),
	))

/**
 * private
 *
 * Analyzes a telemetry packet.
 *
 * Is currently only useful for detecting ban evasion attempts.
 */
/datum/tgui_panel/proc/analyze_telemetry(payload)
	if(world.time > telemetry_requested_at + TGUI_TELEMETRY_RESPONSE_WINDOW)
		message_admins("[key_name(client)] sent telemetry outside of the allocated time window.", R_LOG)
		return
	if(telemetry_analyzed_at)
		message_admins("[key_name(client)] sent telemetry more than once.", R_LOG)
		return
	telemetry_analyzed_at = world.time
	if(!payload)
		return
	
	var/payload_charset = payload["charset"]
	if(istext(payload_charset))
		client.guard.chat_data["charset"] = ckey(payload_charset)

	var/payload_localtime = payload["localTime"]
	if(isnum(payload_localtime))
		client.guard.chat_data["local_time"] = payload_localtime

	telemetry_connections = payload["connections"]
	var/len = length(telemetry_connections)
	if(len == 0)
		client.guard.chat_processed = TRUE
		return
	if(len > TGUI_TELEMETRY_MAX_CONNECTIONS)
		message_admins("[key_name(client)] was kicked for sending a huge telemetry payload", R_LOG)
		qdel(client)
		return

	var/list/found
	for(var/i in 1 to len)
		var/list/row = telemetry_connections[i]

		// Check for a malformed history object
		if (!(row && row["ckey"] && row["address"] && row["computer_id"]))
			continue

		row["ckey"] = ckey(row["ckey"])
		row["address"] = sanitize_ip(row["address"])
		row["computer_id"] = sanitize_numbers(row["computer_id"])

		if (!(row["ckey"] && row["address"] && row["computer_id"]))
			continue

		if (world.IsBanned(row["ckey"], row["address"], row["computer_id"], real_bans_only = TRUE, provided_ckey=ckey(client.ckey)))
			found = row
			break

		CHECK_TICK
		if(QDELETED(client))
			// He got cleaned up before we were done
			return

	// This fucker has a history of playing on a banned account.
	if(found)
		client.guard.chat_data["cookie_match"] = found
		var/msg = "[key_name(client)] has a banned account in connection history! (Matched: [found["ckey"]], [found["address"]], [found["computer_id"]])"
		message_admins(msg, R_LOG)
		log_admin_private(msg)

	client.guard.chat_processed = TRUE
