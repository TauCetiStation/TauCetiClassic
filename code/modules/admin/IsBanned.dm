//How many new ckey matches before we revert the stickyban to it's roundstart state
//These are exclusive, so once it goes over one of these numbers, it reverts the ban
#define STICKYBAN_MAX_MATCHES 15
#define STICKYBAN_MAX_EXISTING_USER_MATCHES 3 //ie, users who were connected before the ban triggered
#define STICKYBAN_MAX_ADMIN_MATCHES 1

// Blocks an attempt to connect before even creating our client datum thing.
// real_bans_only check exists bans, not resticts(WhiteList, GuestPass)
/world/IsBanned(key, address, computer_id, type, real_bans_only = FALSE)
	log_access("ISBANNED: '[args.Join("', '")]'")

	// Shunt world topic banchecks to purely to byond's internal ban system
	if (type == "world")
		return ..()

	var/is_admin = FALSE
	var/ckey = ckey(key)
	var/client/C = global.directory[ckey]

	/* Uncomment this for skip connected clients checks. Broke stckybans sometimes
	// Don't recheck connected clients.
	if (!real_bans_only && istype(C) && ckey == C.ckey && computer_id == C.computer_id && address == C.address)
		return
	*/

	// Whitelist
	if(!real_bans_only && config.serverwhitelist && !check_if_a_new_player(key))
		return list(BANKEY_REASON="", "desc"="[config.serverwhitelist_message]")
	//Guest Checking
	if(!real_bans_only && !guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [key] - Guests not allowed")
		message_admins("<span class='notice'>Failed Login: [key] - Guests not allowed</span>")
		return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
	// Admin allowed anyway
	if (ckey in admin_datums)
		is_admin = TRUE
		if (!C) // first connect admin
			turnoff_stickybans_temporary(ckey)
		return // remove this for admin checks in bans too
	// Check bans
	var/ban = get_ban_blacklist(key, address, computer_id)
	return ban ? ban : stickyban_check(..(), key, computer_id, address, real_bans_only, is_admin) //default pager ban stuff

/world/proc/get_ban_blacklist(key, address, computer_id)
	var/ckey = ckey(key)
	// Legacy ban system
	if(config.ban_legacy_system)
		. = CheckBan( ckey, computer_id, address )
		if(.)
			log_access("Failed Login: [key] [computer_id] [address] - Banned [.[BANKEY_REASON]]")
			message_admins("Failed Login: [key] id:[computer_id] ip:[address] - Banned [.[BANKEY_REASON]]")

	// Database ban system
	else
		if(!establish_db_connection())
			error("Ban database connection failure. Key [ckey] not checked")
			log_misc("Ban database connection failure. Key [ckey] not checked")
			return

		var/failedcid = TRUE
		var/failedip = TRUE
		var/ipquery = ""
		var/cidquery = ""
		if(address)
			failedip = FALSE
			ipquery = " OR ip = '[sanitize_sql(address)]' "
		if(computer_id)
			failedcid = FALSE
			cidquery = " OR computerid = '[sanitize_sql(computer_id)]' "
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM erro_ban WHERE (ckey = '[sanitize_sql(ckey)]' [ipquery] [cidquery]) AND (bantype = 'PERMABAN'  OR (bantype = 'TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		query.Execute()
		while(query.NextRow())
			var/pckey = query.item[1]
			//var/pip = query.item[2]
			//var/pcid = query.item[3]
			var/ackey = query.item[4]
			var/reason = query.item[5]
			var/expiration = query.item[6]
			var/duration = query.item[7]
			var/bantime = query.item[8]
			var/bantype = query.item[9]

			var/expires = ""
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."

			var/desc = "\n"
			desc += "Reason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n"
			desc += "[reason]\n"
			desc += "This ban was applied by [ackey] on [bantime], [expires]"
			return list("reason"="[bantype]", "desc"="[desc]")

		if (failedcid)
			message_admins("[key] has logged in with a blank computer id in the ban check.")
		if (failedip)
			message_admins("[key] has logged in with a blank ip in the ban check.")

/world/proc/stickyban_check(list/byond_ban, key, computer_id, address, real_bans_only, is_admin)
	. = byond_ban
	if (!real_bans_only && byond_ban && islist(byond_ban))
		// Gather basic data
		var/ckey = ckey(key)
		var/client/C = global.directory[ckey]
		var/banned_ckey = "ERROR"
		if(byond_ban[BANKEY_CKEY])
			banned_ckey = byond_ban[BANKEY_CKEY]

		var/newmatch = FALSE
		var/list/cached_ban = SSstickyban.cache[banned_ckey]
		if (cached_ban && islist(cached_ban))
			// drop reverting bans.
			// Timeout will be restored from DB after new round statred
			if (cached_ban[BANKEY_REVERT] || cached_ban[BANKEY_TIMEOUT])
				world.SetConfig("ban", banned_ckey, null)
				return null

			if (ckey != banned_ckey)
				newmatch = TRUE
				if (cached_ban[BANKEY_KEYS] && cached_ban[BANKEY_KEYS][ckey])
					newmatch = FALSE
				if (LAZYACCESS(cached_ban[BANKEY_MATCHES_THIS_ROUND], ckey))
					newmatch = FALSE

			if (newmatch)

				if (C)
					LAZYSET(cached_ban[BANKEY_EXISTING_USER_MATCHES], ckey, ckey)
					LAZYSET(cached_ban[BANKEY_PENDING_MATCHES], ckey, ckey)
					sleep(STICKYBAN_ROGUE_CHECK_TIME)
					LAZYREMOVE(cached_ban[BANKEY_PENDING_MATCHES], ckey)
				if (is_admin)
					LAZYSET(cached_ban[BANKEY_ADMIN_MATCHES_THIS_ROUND], ckey, ckey)
				LAZYSET(cached_ban[BANKEY_MATCHES_THIS_ROUND], ckey, ckey)
				// Checking if we have a lot of matches in already connected clients
				// Then next ban drop from Config after limit
				// When ban not in DB clearing matches too
				// DB restore after sometime rouge bans
				if (length(cached_ban[BANKEY_MATCHES_THIS_ROUND]) + length(cached_ban[BANKEY_PENDING_MATCHES]) > STICKYBAN_MAX_MATCHES || \
					length(cached_ban[BANKEY_EXISTING_USER_MATCHES]) > STICKYBAN_MAX_EXISTING_USER_MATCHES || \
					length(cached_ban[BANKEY_ADMIN_MATCHES_THIS_ROUND]) > STICKYBAN_MAX_ADMIN_MATCHES)
					var/action
					if (byond_ban[BANKEY_FROMDB])
						cached_ban[BANKEY_TIMEOUT] = TRUE
						action = "putting it on timeout for the remainder of the round"
					else
						cached_ban[BANKEY_REVERT] = TRUE
						action = "reverting to its roundstart state"
					world.SetConfig("ban", banned_ckey, null)
					log_game("Stickyban on [banned_ckey] detected as rogue, [action]")
					message_admins("Stickyban on [banned_ckey] detected as rogue, [action]")
					// Do not convert to timer.
					spawn (STICKYBAN_ROGUE_CHECK_TIME)
						world.SetConfig("ban", banned_ckey, null)
						sleep(1)
						world.SetConfig("ban", banned_ckey, null)
						if (!byond_ban[BANKEY_FROMDB])
							cached_ban = cached_ban.Copy()
							// clearing all matches
							cached_ban -= BANKEY_MATCHES_THIS_ROUND
							cached_ban -= BANKEY_PENDING_MATCHES
							cached_ban -= BANKEY_EXISTING_USER_MATCHES
							cached_ban -= BANKEY_ADMIN_MATCHES_THIS_ROUND
							cached_ban -= BANKEY_REVERT
							SSstickyban.cache[banned_ckey] = cached_ban
							world.SetConfig("ban", banned_ckey, list2stickyban(cached_ban))
					return null
		if (byond_ban[BANKEY_FROMDB])
			// update matches DB cache
			INVOKE_ASYNC(SSstickyban, /datum/controller/subsystem/stickyban/proc.update_matches, banned_ckey, ckey, address, computer_id)
		if (is_admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban on [banned_ckey]")
			return null
		// Ckey is already connected
		if (C)
			to_chat(C, "<span class='warning'>You are about to get disconnected for matching a sticky ban after you connected. If this turns out to be the ban evasion detection system going haywire, we will automatically detect this and revert the matches. if you feel that this is the case, please wait EXACTLY 6 seconds then reconnect to see if the match was automatically reversed.</span>")
		var/desc = "\n"
		desc += "Reason:(StickyBan) You, or another user of this computer or connection ([banned_ckey]) is banned from playing here. The ban reason is:\n"
		desc += "[byond_ban[BANKEY_MSG]].\n"
		desc += "This ban was applied by [byond_ban[BANKEY_ADMIN]].\n"
		desc += "This is a BanEvasion Detection System ban, if you think this ban is a mistake, please wait EXACTLY 6 seconds, then try again before filing an appeal.\n"
		. = list("reason" = "Stickyban", "desc" = desc)
		log_access("Failed Login: [key] [computer_id] [address] - StickyBanned [byond_ban[BANKEY_MSG]] Target Username: [banned_ckey] Placed by [byond_ban[BANKEY_ADMIN]]")


/proc/turnoff_stickybans_temporary(admin_ckey, seconds = 5)
	// Oh boy, so basically, because of a bug in byond, sometimes stickyban matches don't trigger here, so we can't exempt admins.
	// Whitelisting the ckey with the byond whitelist field doesn't work.
	// So we instead have to remove every stickyban than later re-add them.

	// Save current Config bans
	if (!length(global.stickyban_admin_exemptions))
		for (var/banned_ckey in world.GetConfig("ban"))
			global.stickyban_admin_texts[banned_ckey] = world.GetConfig("ban", banned_ckey)
			world.SetConfig("ban", banned_ckey, null)
	if (!SSstickyban || !SSstickyban.initialized)
		return
	global.stickyban_admin_exemptions[admin_ckey] = world.time
	// Get time for Config update
	stoplag()
	// Restore on 5 seconds
	global.stickyban_admin_exemption_timer_id = addtimer( \
		CALLBACK(GLOBAL_PROC, /proc/restore_stickybans),  \
		seconds SECONDS, \
		TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_OVERRIDE)

/proc/restore_stickybans()
	// Restore stickybans SetConfig from stickyban_admin_texts
	// Drop timer stickyban_admin_exemption_timer_id
	for (var/banned_ckey in global.stickyban_admin_texts)
		world.SetConfig("ban", banned_ckey, global.stickyban_admin_texts[banned_ckey])
	global.stickyban_admin_exemptions = list()
	global.stickyban_admin_texts = list()
	if (global.stickyban_admin_exemption_timer_id)
		deltimer(global.stickyban_admin_exemption_timer_id)
	global.stickyban_admin_exemption_timer_id = null

#undef STICKYBAN_MAX_MATCHES
#undef STICKYBAN_MAX_EXISTING_USER_MATCHES
#undef STICKYBAN_MAX_ADMIN_MATCHES
