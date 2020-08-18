/datum/admins/proc/stickyban(action, data)
	// Entry point for stickyban admin control
	if(!check_rights(R_BAN))
		return
	switch (action)
		if ("show")
			stickyban_show()
		if ("add")
			stickyban_add(data["ckey"], data["reason"])
		if ("remove")
			stickyban_remove(data["ckey"])
		if ("remove_alt")
			stickyban_remove_alt(data["ckey"], data["alt"])
		if ("edit")
			stickyban_edit(data["ckey"])
		if ("exempt")
			stickyban_exempt(data["ckey"], data["alt"])
		if ("unexempt")
			stickyban_unexempt(data["ckey"], data["alt"])
		if ("timeout")
			stickyban_timeout(data["ckey"])
		if ("untimeout")
			stickyban_untimeout(data["ckey"])
		if ("revert")
			stickyban_revert(data["ckey"])

/datum/admins/proc/stickyban_add(ckey = null, reason = null)
	// Add new stickyban.
	// If ckey or reason null ask usr via input()
	// Sleep by input()
	var/list/ban = list()
	ban[BANKEY_ADMIN] = usr.key
	ban[BANKEY_TYPE] = list("sticky")
	ban[BANKEY_REASON] = "(InGameBan)([usr.key])" //this will be display in dd only
	// Ckey for ban
	if (!ckey)
		ckey = input(usr, "Ckey", "Ckey", "") as text|null
		if (!ckey)
			return
		ckey = ckey(ckey)
	ban[BANKEY_CKEY] = ckey
	if (get_stickyban_from_ckey(ckey))
		to_chat(usr, "Can not add a stickyban: User already has a current sticky ban")
		return
	// Message of ban
	if (istext(reason) && length(reason))
		ban[BANKEY_MSG] = reason
	else
		reason = sanitize(input(usr, "Reason", "Reason", "Ban Evasion") as text|null)
		if (!reason)
			return
		ban[BANKEY_MSG] = "[reason]"
	// Save new stickyban
	SSstickyban.add(ckey, ban)
	log_admin("[key_name(usr)] has stickybanned [ckey].\nReason: [ban[BANKEY_MSG]]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has stickybanned [ckey].\nReason: [ban[BANKEY_MSG]]</span>")

/datum/admins/proc/stickyban_remove(ckey)
	// Can sleep by alerts
	if (!ckey)
		return
	var/ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_exists_check(ckey, ban))
		return
	if (!is_stickyban_from_game(ban))
		to_chat(usr, "<span class='adminnotice'>This user was stickybanned by the host, and can not be un-stickybanned from this panel</span>")
		return
	if (alert("Are you sure you want to remove the sticky ban on [ckey]?", "Are you sure", "Yes", "No") == "No")
		return
	// check again after sleep
	if (!stickyban_ban_exists_check(ckey, get_stickyban_from_ckey(ckey)))
		return
	SSstickyban.remove(ckey)
	log_admin("[key_name(usr)] removed [ckey]'s stickyban")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] removed [ckey]'s stickyban</span>")

/datum/admins/proc/stickyban_ban_exists_check(ckey, list/ban)
	if (!ban)
		to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
		return FALSE
	return TRUE

/datum/admins/proc/stickyban_remove_alt(ckey, ckey_alt)
	// Can sleep by alerts
	if (!ckey || !ckey_alt)
		return
	var/alt = ckey(ckey_alt)
	var/ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_and_alt_exists_check(ban, ckey, alt))
		return
	if (!is_stickyban_from_game(ban))
		alert("This user was stickybanned by the host, and can not be edited from this panel")
		return
	// Confirm
	if (alert("Are you sure you want to disassociate [alt] from [ckey]'s sticky ban? \nNote: Nothing stops byond from re-linking them","Are you sure","Yes","No") == "No")
		return
	// After sleep checking again
	ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_and_alt_exists_check(ban, ckey, alt))
		return
	// Removing alt ckey
	SSstickyban.remove_altkey(ckey, alt, ban)
	log_admin("[key_name(usr)] has disassociated [alt] from [ckey]'s sticky ban")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disassociated [alt] from [ckey]'s sticky ban</span>")

/datum/admins/proc/stickyban_ban_and_alt_exists_check(list/ban, ckey, alt)
	. = FALSE
	if (!ban)
		to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
	else if(!LAZYACCESS(ban[BANKEY_KEYS], alt))
		to_chat(usr, "<span class='adminnotice'>Error: [alt] is not linked to [ckey]'s sticky ban!</span>")
	else
		. = TRUE

/datum/admins/proc/stickyban_edit(ckey)
	// Can sleep by alerts
	if (!ckey)
		return
	var/ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_exists_check(ckey, ban))
		return
	if (!is_stickyban_from_game(ban))
		to_chat(usr, "<span class='adminnotice'>This user was stickybanned by the host, and can not be edited from this panel</span>")
		return
	var/oldreason = ban[BANKEY_MSG]
	var/reason = sanitize(input(usr, "Reason", "Reason", "[ban[BANKEY_MSG]]") as text|null)
	if (!reason || reason == oldreason)
		return
	// We have to do this again incase something changed while we waited for input
	ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_exists_check(ckey, ban))
		return
	SSstickyban.update_reason(ckey, reason, ban)
	log_admin("[key_name(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]</span>")

/datum/admins/proc/stickyban_exempt(ckey, altkey)
	// Checks
	if (!ckey || !altkey)
		return
	var/alt = ckey(altkey)
	var/ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_and_alt_exists_check(ban, ckey, alt))
		return
	if (alert("Are you sure you want to exempt [alt] from [ckey]'s sticky ban?","Are you sure","Yes","No") == "No")
		return
	ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_ban_and_alt_exists_check(ban, ckey, alt))
		return
	// Exempt and remove old altckey matched
	SSstickyban.exempt_alt_ckey(ckey, alt, ban)
	log_admin_private("[key_name(usr)] has exempted [alt] from [ckey]'s sticky ban")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has exempted [alt] from [ckey]'s sticky ban</span>")

/datum/admins/proc/stickyban_whitelist_alt_exists_check(ban, ckey, alt)
	. = FALSE
	if (!ban)
		to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
	else if (!LAZYACCESS(ban[BANKEY_WHITELIST], alt))
		to_chat(usr, "<span class='adminnotice'>Error: [alt] is not exempt from [ckey]'s sticky ban!</span>")
	else
		. = TRUE

/datum/admins/proc/stickyban_unexempt(ckey, altkey)
	if (!ckey || !altkey)
		return
	var/alt = ckey(altkey)
	var/ban = get_stickyban_from_ckey(ckey)
	if (!stickyban_whitelist_alt_exists_check(ban, ckey, alt))
		return
	if (alert("Are you sure you want to unexempt [alt] from [ckey]'s sticky ban?","Are you sure","Yes","No") == "No")
		return
	if (!stickyban_whitelist_alt_exists_check(ban, ckey, alt))
		return
	SSstickyban.unexempt_alt_ckey(ckey, alt, ban)
	log_admin_private("[key_name(usr)] has unexempted [alt] from [ckey]'s sticky ban")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has unexempted [alt] from [ckey]'s sticky ban</span>")

/datum/admins/proc/stickyban_timeout(ckey)
	if (!ckey)
		return
	if (!establish_db_connection())
		to_chat(usr, "<span class='adminnotice'>No database connection!</span>")
		return
	if (alert("Are you sure you want to put [ckey]'s stickyban on timeout until next round (or removed)?","Are you sure","Yes","No") == "No")
		return
	var/ban = get_stickyban_from_ckey(ckey)
	if (!ban)
		to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
		return
	SSstickyban.timeout_before_restart(ckey, ban)
	log_admin_private("[key_name(usr)] has put [ckey]'s sticky ban on timeout.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [ckey]'s sticky ban on timeout.</span>")

/datum/admins/proc/stickyban_untimeout(ckey)
	if (!ckey)
		return
	if (!establish_db_connection())
		to_chat(usr, "<span class='adminnotice'>No database connection!</span>")
		return
	if (alert("Are you sure you want to lift the timeout on [ckey]'s stickyban?","Are you sure","Yes","No") == "No")
		return
	SSstickyban.untimeout(ckey)
	log_admin_private("[key_name(usr)] has taken [ckey]'s sticky ban off of timeout.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has taken [ckey]'s sticky ban off of timeout.</span>")

/datum/admins/proc/stickyban_revert(ckey)
	if (!ckey)
		return
	if (alert("Are you sure you want to revert the sticky ban on [ckey] to its state at round start (or last edit)?","Are you sure","Yes","No") == "No")
		return
	if (!get_stickyban_from_ckey(ckey))
		to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
		return
	if (!SSstickyban.cache[ckey])
		to_chat(usr, "<span class='adminnotice'>Error: No cached sticky ban for [ckey] found! Stickyban will be droped.</span>")
	log_admin_private("[key_name(usr)] has reverted [ckey]'s sticky ban to its state at round start.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has reverted [ckey]'s sticky ban to its state at round start.</span>")
	SSstickyban.reload_from_cache(ckey) // sleep

// Panel renders

/datum/admins/proc/stickyban_gethtml(ckey)
	// Generate HTML for stickyban panel output
	// One record for ckey player
	var/ban = get_stickyban_from_ckey(ckey)
	if (!ban)
		return
	var/src_href = "_src_=holder"
	var/disable_link = "<a href='?[src_href];stickyban=revert&ckey=[ckey]'>Revert</a>"
	establish_db_connection()
	if(dbcon && dbcon.IsConnected())
		disable_link = "<a href='?[src_href];stickyban=[(ban[BANKEY_TIMEOUT] ? "untimeout" : "timeout")]&ckey=[ckey]'>[ban[BANKEY_TIMEOUT] ? "Untimeout" : "Timeout"]</a>"
	var/remove_link = "<a href='?[src_href];stickyban=remove&ckey=[ckey]'>-</a>"
	var/edit_link = "<b><a href='?[src_href];stickyban=edit&ckey=[ckey]'>Edit</a></b>"
	var/owner = "LEGACY"
	if (!is_stickyban_from_game(ban))
		owner = "HOST"
	if (ban[BANKEY_ADMIN])
		owner = "[ban[BANKEY_ADMIN]]"
	var/list/alt_keys_li = list()
	for (var/key in ban[BANKEY_KEYS])
		if (ckey(key) == ckey)
			continue
		var/li = "<li>"
		li += "<a href='?[src_href];stickyban=remove_alt&ckey=[ckey]&alt=[ckey(key)]'>-</a>"
		li += "<a href='?[src_href];stickyban=exempt&ckey=[ckey]&alt=[ckey(key)]'>E</a>"
		li += "[key]"
		li += "</li>"
		alt_keys_li += li
	for (var/key in ban[BANKEY_WHITELIST])
		if (ckey(key) == ckey)
			continue
		var/li = "<li>"
		li += "<a href='?[src_href];stickyban=remove_alt&ckey=[ckey]&alt=[ckey(key)]'>-</a>"
		li += "<a href='?[src_href];stickyban=unexempt&ckey=[ckey]&alt=[ckey(key)]'>UE</a>"
		li += "[key]"
		li += "</li>"
		alt_keys_li += li
	var/alt_keys = ""
	if (length(alt_keys_li))
		alt_keys +="Caught keys:<br/><ol>[alt_keys_li.Join("")]</ol>"
	// Can be easy converted to table or div on stickyban_show
	return list(
		"[remove_link][disable_link]",
		"<b>[ckey]</b>",
		"[ban[BANKEY_MSG]][edit_link]",
		"[owner]",
		"[alt_keys]"
	)

/datum/admins/proc/stickyban_show()
	// Show browser window for stickyban panel if R_BAN rights
	if(!check_rights(R_BAN))
		return
	var/list/bans = sticky_banned_ckeys()
	var/header = "<title>Sticky Bans</title><style> .sign{ font-style: italic;}</style>"
	var/title = "Sticky Bans <a href='?_src_=holder;stickyban=add'>Add</a>"
	var/list/html_bans_data = list()
	for(var/ckey in bans)
		var/list/ban_html_record = stickyban_gethtml(ckey)
		if (length(ban_html_record))
			html_bans_data += {"<div class="line">[ban_html_record[1]] [ban_html_record[2]]</div>
					<div class="block">[ban_html_record[3]]</div><div class="sign">By [ban_html_record[4]]</div>
					<div>[ban_html_record[5]]</div>"}
	var/content = html_bans_data.Join("<hr/>")
	var/datum/browser/browser = new(owner.mob, "stickybans", title, 700, 400)
	browser.add_head_content(header)
	browser.set_content(content)
	browser.open()

/client/proc/stickybanpanel()
	set name = "Sticky Ban Panel"
	set category = "Admin"
	if (!holder)
		return
	holder.stickyban_show()
