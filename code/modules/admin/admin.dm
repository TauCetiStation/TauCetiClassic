
var/global/BSACooldown = 0


////////////////////////////////
/proc/message_admins(msg, reg_flag = R_ADMIN, emphasize = FALSE)
	log_adminwarn(msg) // todo: msg in html format, dublicates other logs; must be removed, use logs_*() where necessary (also, thanks you dear ZVE)
	var/style = "admin"
	if (emphasize)
		style += " emphasized"
	msg = "<span class='[style]'><span class='prefix'>ADMIN LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C as anything in admins)
		if(C.holder.rights & reg_flag)
			to_chat_admin_log(C, msg)

// do not use with formatted messages (html), we don't need it in logs
/proc/admin_log_and_message_admins(message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message, 1)

/proc/msg_admin_attack(msg, mob/living/target) //Toggleable Attack Messages
	log_attack(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[msg]</span></span> [ADMIN_PPJMPFLW(target)]"


	var/require_flags = CHAT_ATTACKLOGS
	if(!target.client && !ishuman(target))
		require_flags |= CHAT_NOCLIENT_ATTACK

	for(var/client/C as anything in admins)
		if(!(R_ADMIN & C.holder.rights))
			continue
		if((C.prefs.chat_toggles & require_flags) != require_flags)
			continue
		to_chat_attack_log(C, msg)


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/body = ""
	body += "Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "<A href='?src=\ref[src];editrights=show'>[M.client.holder ? M.client.holder.rank : "Player"]</A>"

	if(isnewplayer(M))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " - <A href='?src=\ref[src];revive=\ref[M]'>Heal</A>"

	body += {"
		<br><br>
		<a href='?_src_=vars;Vars=\ref[M]'>VV</a> -
		<a href='?src=\ref[src];traitor=\ref[M]'>TP</a> -
		<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> -
		<a href='?src=\ref[src];subtlemessage=\ref[M]'>SM</a> -
		<a href='?src=\ref[src];adminplayerobservefollow=\ref[M]'>FLW</a>
		<br>
		<b>Mob type</b> = [M.type]<br><br>
		<b>Guard:</b> <A href='?src=\ref[src];guard=\ref[M]'>Show</A> |
		<b>List of CIDs:</b> <A href='?src=\ref[src];cid_list=\ref[M]'>Get</A>|<A href='?src=\ref[src];cid_ignore=\ref[M]'>Ignore Warning</A><br>
		<b>Related accounts by IP and cid</b>: <A href='?src=\ref[src];related_accounts=\ref[M]'>Get</A><br>
		<b>CentCom (other server bans)</b>: <A target='_blank' href='https://centcom.melonmesa.com/viewer/view/[M.ckey]'>CentCom (ENG)</A><br>
		<b>BYOND profile</b>: <A target='_blank' href='http://byond.com/members/[M.ckey]'>[M.ckey]</A><br><br>
		<A href='?src=\ref[src];boot2=\ref[M]'>Kick</A> |
		<A href='?_src_=holder;warn=[M.ckey]'>Warn</A> |
		<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> |
		<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> |
		<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A>
	"}

	if(M.client)
		body += "| <A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A><br>"
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			<A class='[(muted & MUTE_IC)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'>IC</a>
			<A class='[(muted & MUTE_OOC)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'>OOC</a>
			<A class='[(muted & MUTE_PRAY)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'>PRAY</a>
			<A class='[(muted & MUTE_ADMINHELP)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'>ADMINHELP</a>
			<A class='[(muted & MUTE_MENTORHELP)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_MENTORHELP]'>MENTORHELP</a>
			<A class='[(muted & MUTE_DEADCHAT)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'>DEADCHAT</a>
			<A class='[(muted & MUTE_ALL)?"red":"green"]' href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'>ALL</a>
		"}

	body += {"<br><br>
		<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> |
		<A href='?src=\ref[src];getmob=\ref[M]'>Get</A> |
		<A href='?src=\ref[src];sendmob=\ref[M]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN,0) ? "<A href='?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> | " : "" ]
		<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> |
		<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A> |
		<A href='?src=\ref[src];skills=\ref[M]'>Skills panel</A>
	"}

	if (M.client)
		if(!isnewplayer(M))
			body += "<br>"
			body += "<div class='Section'>"
			body += "<h3>Transformations:</h3>"

			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?src=\ref[src];corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += {"<A href='?src=\ref[src];makeai=\ref[M]'>Make AI</A> |
					<A href='?src=\ref[src];makerobot=\ref[M]'>Make Robot</A> |
					<A href='?src=\ref[src];makealien=\ref[M]'>Make Alien</A> |
					<A href='?src=\ref[src];makeslime=\ref[M]'>Make slime</A> |
					<A href='?src=\ref[src];makeblob=\ref[M]'>Make Blob</A> |
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Re-Animalize</A> "
			else
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Animalize</A> "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table>"
				for(var/block in 1 to DNA_SE_LENGTH)
					if(((block-1)%5)==0)
						body += "</tr><tr>"
					var/bname = assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"green":"red"]"
						body += "<A class='[bcolor]' href='?src=\ref[src];togmutate=\ref[M];block=[block]'><font size='0.5em'>[block]</font>.[bname]</A>"
					else
						body += "[block]"
					body+="</td>"
				body += "</table>"

			body += {"<br>
				<h4>Rudimentary transformations:</h4>
				<i>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</i><br>
				<A href='?src=\ref[src];simplemake=observer;mob=\ref[M]'>Observer</A>
				<A href='?src=\ref[src];simplemake=human;mob=\ref[M]'>Human</A>
				<A href='?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Monkey</A>
				<A href='?src=\ref[src];simplemake=robot;mob=\ref[M]'>Cyborg</A>|
				Alien: <A href='?src=\ref[src];simplemake=drone;mob=\ref[M]'>Drone</A>
				<A href='?src=\ref[src];simplemake=hunter;mob=\ref[M]'>Hunter</A>
				<A href='?src=\ref[src];simplemake=queen;mob=\ref[M]'>Queen</A>
				<A href='?src=\ref[src];simplemake=sentinel;mob=\ref[M]'>Sentinel</A>
				<A href='?src=\ref[src];simplemake=larva;mob=\ref[M]'>Larva</A>|
				Slime: <A href='?src=\ref[src];simplemake=slime;mob=\ref[M]'>Baby</A>
				<A href='?src=\ref[src];simplemake=adultslime;mob=\ref[M]'>Adult</A>|
				<A href='?src=\ref[src];simplemake=cat;mob=\ref[M]'>Cat</A>
				<A href='?src=\ref[src];simplemake=dusty;mob=\ref[M]'>Dusty</A>
				<A href='?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Corgi</A>
				<A href='?src=\ref[src];simplemake=crab;mob=\ref[M]'>Crab</A>
				<A href='?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Coffee</A>|
				Construct: <A href='?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Armoured</A>
				<A href='?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Builder</A>
				<A href='?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Wraith</A>
				<A href='?src=\ref[src];simplemake=shade;mob=\ref[M]'>Shade</A>
				<br>
			"}
			body += "</div>"
	if (M.client)
		body += {"<h3>Other actions:</h3>
			<A href='?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A> |
			<A href='?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> |
			<A href='?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> |
			<A href='?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> |
			<A href='?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A>
		"}

	var/datum/browser/popup = new(usr, "adminplayeropts", "Options for [M.key]", 550, 700)
	popup.set_content(body)
	popup.open()

	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


#define PLAYER_INFO_MISSING_CONTENT_TEXT    "Missing Data"
#define PLAYER_INFO_MISSING_AUTHOR_TEXT     "N/A"
#define PLAYER_INFO_MISSING_RANK_TEXT       "N/A"
#define PLAYER_INFO_MISSING_TIMESTAMP_TEXT  "N/A"
#define PLAYER_INFO_MISSING_JOB_TEXT        "N/A"
#define PLAYER_INFO_MISSING_ROUND_ID_TEXT   "N/A"

/datum/player_info
	var/author = PLAYER_INFO_MISSING_AUTHOR_TEXT        // admin who authored the information
	var/content = PLAYER_INFO_MISSING_CONTENT_TEXT      // text content of the information
	var/timestamp = PLAYER_INFO_MISSING_TIMESTAMP_TEXT  // Because this is bloody annoying
	var/days_timestamp = 0 // number of day after 1 Jan 2000
	var/round_id = PLAYER_INFO_MISSING_ROUND_ID_TEXT
	var/ingameage = 0

/datum/player_info/proc/get_days_timestamp()
	return isnum(days_timestamp) ? days_timestamp : 0

/datum/admins/proc/show_player_notes(key)
	if(!(check_rights(R_LOG) && check_rights(R_BAN)))
		return

	key = ckey(key)

	if(!key || !config.sql_enabled)
		return

	if(!establish_db_connection("erro_messages", "erro_ban"))
		to_chat(usr, "Notes [key] from DB don't available.")
		return

	//Display player age and player warn bans
	var/p_age
	var/p_ingame_age
	for(var/client/C in clients)
		if(C.ckey == key)
			p_age = C.player_age
			p_ingame_age = C.player_ingame_age

	// Gather data
	var/list/db_messages = load_info_player_db_messages(key)
	var/list/db_bans = load_info_player_db_bans(key)
	// Start render info page
	var/dat = ""
	dat +="<span style='color:#000000; font-weight: bold'>Player age: [p_age] / In-game age: [p_ingame_age]</span><hr>"

	if(!length(db_messages) && !length(db_bans))
		dat += "No information found on the given key.<br>"
	else
		var/list/infos = generalized_players_info(db_messages, db_bans)
		for(var/datum/player_info/I in infos)
			dat += "<font color=#008800>[I.content]</font> <i>by [I.author]</i> on <i><font color=blue>#[I.round_id], [I.timestamp] ([I.ingameage] player minutes)</i></font> "
			dat += "<br><br>"
	dat += "<br>"
	dat += "<A href='?src=\ref[src];add_player_info=[key]'>Add Comment</A><br>"

	var/datum/browser/popup = new(usr, "window=adminplayerinfo", "Info on [key]", 480, 480, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/generalized_players_info(list/file_notes, list/db_notes)
	var/list/datum/player_info/merged = list()
	if(length(file_notes))
		merged += file_notes
	if(length(db_notes))
		merged += db_notes
	merged = sortMerge(merged, GLOBAL_PROC_REF(cmp_days_timestamp), FALSE)
	return merged

/proc/cmp_days_timestamp(datum/player_info/a, datum/player_info/b)
	return a.get_days_timestamp() - b.get_days_timestamp()

/datum/admins/proc/load_info_player_db_messages(player_ckey)
	// Get player ckey and generate list of players_notes
	// Return null if errors
	var/list/db_player_notes = list()
	var/timestamp_format = "%a, %M %D of %Y" // we don't really need it now because both bans and notes use normal timestamp, but i'm little tired
	var/days_ago_start_date = "1999-12-31"   // to make changes here ang test, and anyway we will rewrite it completely
	var/list/sql_fields = list(
		"adminckey",
		"text",
		"DATE_FORMAT(timestamp, '[timestamp_format]')",
		"DATEDIFF(timestamp, '[days_ago_start_date]')",
		"round_id",
		"ingameage"
	 )
	var/DBQuery/query = dbcon.NewQuery("SELECT " + sql_fields.Join(", ") + " FROM erro_messages WHERE (targetckey = '[ckey(player_ckey)]') AND (deleted = 0) ORDER BY id LIMIT 100")
	if(!query.Execute())
		return
	while(query.NextRow())
		var/datum/player_info/notes_record = new()

		var/a_ckey = query.item[1]
		var/text = query.item[2]
		var/timestamp = query.item[3]
		var/days_ago = text2num(query.item[4])
		var/rid = text2num(query.item[5])
		var/ingameage = text2num(query.item[6])

		if(length(a_ckey))
			notes_record.author = a_ckey
		if(length(text))
			notes_record.content = text
		if(length(timestamp))
			notes_record.timestamp = timestamp
		if(days_ago)
			notes_record.days_timestamp = days_ago
		if(rid)
			notes_record.round_id = rid
		if(ingameage)
			notes_record.ingameage = ingameage

		db_player_notes += notes_record

	return db_player_notes

/datum/admins/proc/load_info_player_db_bans(player_ckey)
	// Get player ckey and generate list of players_notes
	// Return null if errors
	var/list/db_player_notes = list()
	if(config.ban_legacy_system)
		return
	var/timestamp_format = "%a, %M %D of %Y"
	var/days_ago_start_date = "1999-12-31"
	var/list/sql_fields = list(
		"a_ckey",
		"bantype",
		"reason",
		"DATE_FORMAT(bantime, '[timestamp_format]')",
		"ip",
		"computerid",
		"duration",
		"job",
		"DATEDIFF(bantime, '[days_ago_start_date]')",
		"unbanned",
		"DATE_FORMAT(unbanned_datetime, '[timestamp_format]')",
		"DATEDIFF(unbanned_datetime, '[days_ago_start_date]')",
		"unbanned_ckey",
		"round_id",
		"ingameage"
	 )
	var/DBQuery/query = dbcon.NewQuery("SELECT " + sql_fields.Join(", ") + " FROM erro_ban WHERE (ckey = '[ckey(player_ckey)]') ORDER BY id LIMIT 100")
	if(!query.Execute())
		return
	while(query.NextRow())
		var/datum/player_info/notes_record = new()
		var/datum/player_info/unban_notes_record
		var/list/ip_cid = list()
		var/a_ckey = query.item[1]
		var/bantype = query.item[2]
		var/reason = query.item[3]
		var/timestamp = query.item[4]
		if(query.item[5])
			ip_cid += query.item[5]
		if(query.item[6])
			ip_cid += query.item[6]
		var/duration = text2num(query.item[7])
		var/job = query.item[8] ? query.item[8] : PLAYER_INFO_MISSING_JOB_TEXT
		var/days_ago = text2num(query.item[9])
		var/is_unbanned = query.item[10] ? TRUE : FALSE
		var/unbanned_timestamp = query.item[11]
		var/unbanned_days_ago = text2num(query.item[12])
		var/unbanned_a_ckey = query.item[13]
		var/rid = text2num(query.item[14])
		var/ingameage = text2num(query.item[15])

		if(rid)
			notes_record.round_id = rid

		if(ingameage)
			notes_record.round_id = ingameage

		// -1 = perma, duration in minutes come
		if(!duration)
			duration = "N/A"
		else if(duration < 0)
			duration = "infinity"
		else
			duration = DisplayTimeText((duration MINUTE), 1)

		// Ban Record creating
		if(length(a_ckey))
			notes_record.author = a_ckey
		var/description = "([ip_cid.Join(", ")]): [reason]"
		switch(bantype)
			if (BANTYPE_JOB_PERMA_STR)
				// notes_record.content = "Permanent JOB BAN [job] [description]"
				// already in notes by Adminbot
				continue
			if (BANTYPE_JOB_TEMP_STR)
				// notes_record.content = "Temporal JOB BAN [job] for [duration] [description]"
				continue
			if (BANTYPE_PERMA_STR)
				notes_record.content = "Permanent BAN [description]"
			if (BANTYPE_TEMP_STR)
				notes_record.content = "Temporal BAN for [duration] [description]"
		if(length(timestamp))
			notes_record.timestamp = timestamp
		if(days_ago)
			notes_record.days_timestamp = days_ago
		db_player_notes += notes_record

		// Unban record creating
		if(is_unbanned)
			unban_notes_record = new()
			if(length(unbanned_a_ckey))
				unban_notes_record.author =  unbanned_a_ckey
			switch(bantype)
				if(BANTYPE_JOB_PERMA_STR)
					unban_notes_record.content = "Unban. Permanent JOB BAN [job] was [timestamp]"
				if(BANTYPE_JOB_TEMP_STR)
					unban_notes_record.content = "Unban. Temporal JOB BAN [job] was [timestamp]"
				if(BANTYPE_PERMA_STR)
					unban_notes_record.content = "Unban. Permanent BAN was [timestamp]"
				if(BANTYPE_TEMP_STR)
					unban_notes_record.content = "Unban. Temporal BAN was [timestamp]"
			if(length(unbanned_timestamp))
				unban_notes_record.timestamp = unbanned_timestamp
			if(unbanned_days_ago)
				unban_notes_record.days_timestamp = unbanned_days_ago
			db_player_notes += unban_notes_record
	return db_player_notes

#undef PLAYER_INFO_MISSING_ROUND_ID_TEXT
#undef PLAYER_INFO_MISSING_CONTENT_TEXT
#undef PLAYER_INFO_MISSING_AUTHOR_TEXT
#undef PLAYER_INFO_MISSING_RANK_TEXT
#undef PLAYER_INFO_MISSING_TIMESTAMP_TEXT
#undef PLAYER_INFO_MISSING_JOB_TEXT


/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/dat = ""

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!
			"}
			if(news_network.wanted_issue)
				dat+= "<HR><A href='?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><A href='?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>
				<BR><A href='?src=\ref[src];ac_view=1'>View Feed Channels</A>
				<BR><A href='?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>
			"}

			var/wanted_already = 0
			if(news_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR><B>Feed Security functions:</B><BR>
				<BR><A href='?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
				<BR><A href='?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>
				<BR><A href='?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice (disables and locks the channel.</A>
				<BR><HR><A href='?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admincaster_signature]</FONT></A>
			"}
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( isemptylist(news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR></B>"
			dat+={"<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR><B><A href='?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B><A href='?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><A href='?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR><B><A href='?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B>Message Author:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>
				<BR><A href='?src=\ref[src];ac_submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
			dat+={"
				<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='?src=\ref[src];ac_setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				<B>Nanotrasen Feed Censorship Tool</B><BR>
				<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
				Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				<B>Nanotrasen D-Notice Handler</B><HR>
				<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's
				morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
				stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>
			"}
			if( isemptylist(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
						<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>
					"}
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
			dat+={"
				<HR>
				<A href='?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<A href='?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.admincaster_signature]</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.</FONT><BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				<B>Wanted Issue successfully deleted from Circulation</B><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>
				<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
				<B>Description</B>: [news_network.wanted_issue.body]<BR>
				<B>Photo:</B>:
			"}
			if(news_network.wanted_issue.img)
				usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] successfully edited.</FONT><BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//world << "Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]"
	//world << "Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]"

	var/datum/browser/popup = new(usr, "window=admincaster_main", "Admin Newscaster", 400, 600)
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(master_mode == "Secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>Force Secret Mode</A><br>"

	dat += {"
		<BR>
		<A href='?src=\ref[src];show_raspect=1'>Show Round Aspect</A><br>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<br><A href='?src=\ref[src];vsc=airflow'>Edit Airflow Settings</A><br>
		<A href='?src=\ref[src];vsc=phoron'>Edit Phoron Settings</A><br>
		<A href='?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	var/datum/browser/popup = new(usr, "admin2", "Game Panel", 210, 280)
	popup.set_content(dat)
	popup.open()
	return

/datum/admins/proc/change_crew_salary()

	var/list/crew = my_subordinate_staff("Admin")
	var/dat

	dat += "<A href='byond://?src=\ref[src];global_salary=1'>Globally change crew salaries</A><br>"
	dat += "<small>Globally - this is a change in salary for the profession. New players will enter the round with a changed salary. To return the base salary, select 0.</small><hr>"
	dat += "<div class='Section'>"
	if(crew.len)
		dat += "<table>"
		dat += "<tr><th>Name</th><th>Rank</th><th>Salary</th><th>Control</th></tr>"
		for(var/person in crew)
			var/datum/money_account/acc = get_account(person["account"])
			if(!acc)
				continue

			var/color = "silver"
			if(acc.owner_salary > acc.base_salary)
				color = "green"
			else if(acc.owner_salary < acc.base_salary)
				color = "red"
			dat += "<tr><td><span class='highlight'>[person["name"]]</span></td><td><span class='average'>[person["rank"]]</span></td>"
			dat += "<td><font color='[color]'><b>[person["salary"]]$</b></font></td>"
			dat += "<td><A href='byond://?src=\ref[src];salary=[person["account"]]'>Change</A></td></tr>"
		dat += "</table>"
	else
		dat += "<span class='bad'>Crew not found!</span>"
	dat += "</div>"

	var/datum/browser/popup = new(usr, "window=admin_salary", "Crew Salary")
	popup.set_content(dat)
	popup.open()


/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = tgui_alert(usr, "Restart the game world? Warning: game stats will be lost if round not ended.", "Restart", list("Yes", "Cancel"))
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		to_chat(world, "<span class='warning'><b>Restarting world!</b> <span class='notice'>Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!</span></span>")
		log_admin("[key_name(usr)] initiated a reboot.")

		feedback_set_details("end_error","admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
		feedback_add_details("admin_verb","R") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		if(blackbox)
			blackbox.save_all_data_to_sql()

		sleep(50)
		world.Reboot(end_state = "admin reboot - by [usr.key]")

/datum/admins/proc/end_round()
	set category = "Server"
	set name = "End Round"

	if(tgui_alert(usr, "This will finish the round, but print and save all statistics. Are you sure?", "Restart", list("Yes", "Cancel")) != "Yes")
		return

	SSticker.force_end = TRUE

/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))
		return

	var/message = sanitize(input("Global message to send:", "Admin Announce", null, null)  as message, MAX_PAPER_MESSAGE_LEN, extra = 0)

	if(message)
		do_admin_announce(message, (usr.client.holder.fakekey ? "Administrator" : usr.key))
		log_admin("Announce: [key_name(usr)] : [message]")
		feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/do_admin_announce(message, from)
	to_chat(world, "<span class='admin_announce'><b>[from] Announces:</b>\n <span class='italic emojify linkify'>[message]</span></span>")

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	ooc_allowed = !ooc_allowed

	world.send2bridge(
		type = list(BRIDGE_OOC),
		attachment_msg = "[key_name(usr)] toggled OOC [ooc_allowed ? "on" : "off"]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

	to_chat(world, "<B>The OOC channel has been globally [ooc_allowed ? "enabled" : "disabled"]!</B>")

	log_admin("[key_name(usr)] toggled OOC [ooc_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(usr)] toggled OOC [ooc_allowed ? "on" : "off"].")

	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"
	looc_allowed = !( looc_allowed )
	if (looc_allowed)
		to_chat(world, "<B>The LOOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The LOOC channel has been globally disabled!</B>")
	log_admin("[key_name(usr)] toggled LOOC.")
	message_admins("[key_name_admin(usr)] toggled LOOC.")
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"
	dsay_allowed = !( dsay_allowed )
	if (dsay_allowed)
		to_chat(world, "<B>Deadchat has been globally enabled!</B>")
	else
		to_chat(world, "<B>Deadchat has been globally disabled!</B>")
	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.")
	feedback_add_details("admin_verb","TDSAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle OOC for people in lobby(and or ghosts for some non-apparent reason)."
	set name="Toggle Dead/Lobby OOC"
	dooc_allowed = !( dooc_allowed )

	log_admin("[key_name(usr)] toggled Dead/Lobby OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead/Lobby OOC.")
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].")
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"

	if(SSticker.current_state < GAME_STATE_PREGAME)
		to_chat(usr, "<span class='danger large'>Unable to start the game as it is not yet set up.</span>")
		SSticker.start_ASAP = !SSticker.start_ASAP
		if(SSticker.start_ASAP)
			to_chat(usr, "<span class='warning large'>The game will begin as soon as possible.</span>")
			log_admin("[key_name(usr)] will begin the game as soon as possible.")
			message_admins("<font color='blue'>[key_name_admin(usr)] will begin the game as soon as possible.</font>")
		else
			to_chat(usr, "<span class='warning large'>The game will begin as normal.</span>")
			log_admin("[key_name(usr)] will begin the game as normal.")
			message_admins("<font color='blue'>[key_name_admin(usr)] will begin the game as normal.</font>")
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return FALSE

	if(SSticker.start_now())
		log_admin("[key_name(usr)] has started the game.")
		message_admins("<font color='blue'>[key_name_admin(usr)] has started the game.</font>")
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return TRUE
	else
		to_chat(usr, "<span class='warning'>Error: Start Now: Game has already started.</span>")

	return FALSE

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	if(!SSlag_switch.initialized)
		return
	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, !SSlag_switch.measures[DISABLE_NON_OBSJOBS])
	log_admin("[key_name(usr)] toggled new player game entering [SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "OFF" : "ON"].")
	message_admins("[key_name_admin(usr)] toggled new player game entering [SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "OFF" : "ON"].")

	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn :(</B>")
	message_admins("[key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_aliens()
	set category = "Server"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	aliens_allowed = !aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [aliens_allowed ? "on" : "off"].")
	feedback_add_details("admin_verb","TA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_space_ninja()
	set category = "Server"
	set desc="Toggle space ninjas spawning."
	set name="Toggle Space Ninjas"
	toggle_space_ninja = !toggle_space_ninja
	log_admin("[key_name(usr)] toggled Space Ninjas to [toggle_space_ninja].")
	message_admins("[key_name_admin(usr)] toggled Space Ninjas [toggle_space_ninja ? "on" : "off"].")
	feedback_add_details("admin_verb","TSN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/change_FH_control_type()
	set category = "Server"
	set desc="Change facehuggers control type"
	set name="Change FH control type"
	var/FH_control_type = input("Choose a control type of facehuggers.","FH control type") as null|anything in list("Playable(+SAI)(default)", "Dynamic AI", "Static AI")
	feedback_add_details("admin_verb","CFHAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	switch(FH_control_type)
		if("Static AI")
			facehuggers_control_type = FACEHUGGERS_STATIC_AI
			for(var/obj/item/clothing/mask/facehugger/FH in facehuggers_list)
				STOP_PROCESSING(SSobj, FH)
		if("Dynamic AI")
			facehuggers_control_type = FACEHUGGERS_DYNAMIC_AI
			for(var/obj/item/clothing/mask/facehugger/FH in facehuggers_list)
				START_PROCESSING(SSobj, FH)
		if("Playable(+SAI)(default)")
			facehuggers_control_type = FACEHUGGERS_PLAYABLE
			for(var/obj/item/clothing/mask/facehugger/FH in facehuggers_list)
				STOP_PROCESSING(SSobj, FH)
	if(FH_control_type)
		to_chat(observer_list, "<B>Facehuggers' control type was changed. Now you can [(facehuggers_control_type == FACEHUGGERS_PLAYABLE) ? "" : "no longer"] control the facehugger</B>")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] changed facehuggers' control type to: [FH_control_type].</span>")

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start"
	set name="Delay pre-game"

	if(!check_rights(R_SERVER))	return
	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(SSticker.timeLeft/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return tgui_alert(usr, "Too late... The game has already started!")
	if(newtime)
		SSticker.timeLeft = newtime * 10
		if(newtime < 0)
			to_chat(world, "<b>The game start has been delayed.</b>")
			log_admin("[key_name(usr)] delayed the round start.")
			world.send2bridge(
				type = list(BRIDGE_ROUNDSTAT),
				attachment_msg = "**[key_name(usr)]** delayed the round start",
				attachment_color = BRIDGE_COLOR_ROUNDSTAT,
			)
		else
			to_chat(world, "<b>The game will start in [newtime] seconds.</b>")
			log_admin("[key_name(usr)] set the pre-game delay to [newtime] seconds.")
			world.send2bridge(
				type = list(BRIDGE_ROUNDSTAT),
				attachment_msg = "**[key_name(usr)]** set the pre-game delay to [newtime] seconds.",
				attachment_color = BRIDGE_COLOR_ROUNDSTAT,
			)
		feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay_end()
	set category = "Server"
	set desc="Delay the game end"
	set name="Delay end-game"

	if(!check_rights(R_SERVER))	return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		SSticker.admin_delayed = !SSticker.admin_delayed
		log_admin("[key_name(usr)] [SSticker.admin_delayed ? "delayed the round end" : "has made the round end normally"].")
		message_admins("<span class='adminnotice'>[key_name(usr)] [SSticker.admin_delayed ? "delayed the round end" : "has made the round end normally"].</span>")
		world.send2bridge(
			type = list(BRIDGE_ROUNDSTAT),
			attachment_msg = "**[key_name(usr)]** [SSticker.admin_delayed ? "delayed the round end" : "has made the round end normally"].",
			attachment_color = BRIDGE_COLOR_ROUNDSTAT,
		)
	else
		return tgui_alert(usr, "The game has not started yet!")

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("<span class='notice'>Toggled admin jumping to [config.allow_admin_jump].</span>")
	feedback_add_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("<span class='notice'>Toggled admin item spawning to [config.allow_admin_spawning].</span>")
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("<span class='notice'>Toggled reviving to [config.allow_admin_rev].</span>")
	feedback_add_details("admin_verb","TAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)	return
	if(tgui_alert(usr, "Reboot server?",, list("Yes","No")) == "No")
		return
	to_chat(world, "<span class='warning'><b>Rebooting world!</b> <span class='notice'>Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!</span></span>")
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	world.Reboot(end_state = "immediate admin reboot - by [usr.key]")

/datum/admins/proc/toggle_job_restriction()
	set category = "Server"
	set desc="Toggles job restrictions for aliens"
	set name="Toggle Job Restriction"

	if(!check_rights(R_WHITELIST))
		return
	config.use_alien_job_restriction = !config.use_alien_job_restriction
	to_chat(world, "Job restrictions for xenos was [config.use_alien_job_restriction ? "en" : "dis"]abled.")
	message_admins("[key_name(usr)] toggled Job restrictions for xenos.")
	feedback_add_details("admin_verb","TJR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_deathmatch_arena()
	set category = "Server"
	set desc = "Toggle arena on the round end."
	set name = "Toggle Roundend Deathmatch"
	config.deathmatch_arena = !config.deathmatch_arena
	log_admin("[key_name(usr)] toggled Deathmatch Arena to [config.deathmatch_arena].")
	message_admins("[key_name_admin(usr)] toggled Deathmatch Arena [config.deathmatch_arena ? "on" : "off"].")
	feedback_add_details("admin_verb","TDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(mob/M in mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (is_centcom_level(M.z))
		if (config.allow_admin_jump)
			M.loc = pick(latejoin)
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]")
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			tgui_alert(usr, "Admin jumping disabled")
	else
		tgui_alert(usr, "[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(mob/M) // returns 1 for specail characters and 2 for heroes of gamemode
	if(!SSticker || !SSticker.mode || !istype(M))
		return 0
	if(isanyantag(M) || M.mind?.special_role)
		for(var/id in M.mind.antag_roles)
			var/datum/role/role = M.mind.antag_roles[id]
			if(role.is_roundstart_role)
				return 2
		return 1

	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return 1

	return 0

/*
/datum/admins/proc/get_sab_desc(target)
	switch(target)
		if(1)
			return "Destroy at least 70% of the phoron canisters on the station"
		if(2)
			return "Destroy the AI"
		if(3)
			var/count = 0
			for(var/mob/living/carbon/monkey/Monkey in not_world)
				if(Monkey.z == ZLEVEL_STATION)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(4)
			return "Cut power to at least 80% of the station"
		else
			return "Error: Invalid sabotage target: [target]"
*/
/datum/admins/proc/spawn_atom()
	set category = "Debug"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))
		return

	var/target_path = input("Enter typepath:", "Typepath", "mob/living/carbon/human?")
	var/chosen = text2path(target_path)
	if(!ispath(chosen))
		chosen = pick_closest_path(target_path)
		if(!chosen)
			tgui_alert(usr, "No path was selected")
			return
		else if(ispath(chosen, /area))
			tgui_alert(usr, "That path is not allowed.")
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_admin("[key_name(usr)] spawned [chosen] at [COORD(usr)]")
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(mob/M in mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role."
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/show_skills_panel(mob/M)

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind! So no skills!")
		return

	M.mind.edit_skills()
	feedback_add_details("admin_verb","SKP")

/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	tinted_weldhelh = !( tinted_weldhelh )
	if (tinted_weldhelh)
		to_chat(world, "<B>The tinted_weldhelh has been enabled!</B>")
	else
		to_chat(world, "<B>The tinted_weldhelh has been disabled!</B>")
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.")
	feedback_add_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	guests_allowed = !( guests_allowed )
	if (!( guests_allowed ))
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.")
	message_admins("[key_name_admin(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.")
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S as anything in silicon_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, usr)]'s laws:</b>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>")
		else if (ispAI(S))
			to_chat(usr, "<b>pAI [key_name(S, usr)]'s laws:</b>")
			var/mob/living/silicon/pai/P = S
			to_chat(usr, "pAI's master: <b>[P.master ? P.master : "N/A"]</b>" )
		else
			to_chat(usr, "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>")

		if (S.laws == null)
			to_chat(usr, "[key_name(S, usr)]'s laws are null?? Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>")//Just so you know the thing is actually working and not just ignoring you.

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()

/datum/admins/proc/show_lag_switch_panel()
	set category = "Server"
	set name = "Show Lag Switches"
	set desc="Display the controls for drastic lag mitigation measures."

	if(!SSlag_switch.initialized)
		to_chat(usr, "<span class='notice'>The Lag Switch subsystem has not yet been initialized.</span>")
		return
	if(!check_rights(R_SERVER))
		return

	var/html = ""

	html += "<div class='Section__title'>Settings</div><div class='Section'>"
	html += "Automatic Trigger: <a href='?_src_=holder;change_lag_switch_option=TOGGLE_AUTO'><b>[SSlag_switch.auto_switch ? "On" : "Off"]</b></a><br>"
	html += "Population Threshold: <a href='?_src_=holder;change_lag_switch_option=NUM'><b>[SSlag_switch.trigger_pop]</b></a><br>"
	html += "Slowmode Cooldown (toggle On/Off below): <a href='?_src_=holder;change_lag_switch_option=SLOWCOOL'><b>[SSlag_switch.slowmode_cooldown/10] seconds</b></a><br>"
	html += "<br><b>SET ALL MEASURES: <a href='?_src_=holder;change_lag_switch=ALL_ON'>ON</a> | <a href='?_src_=holder;change_lag_switch=ALL_OFF'>OFF</a></b><br>"
	html += "Disable late joining: <a href='?_src_=holder;change_lag_switch=[DISABLE_NON_OBSJOBS]'><b>[SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "On" : "Off"]</b></a>"
	html += "</div>"

	html += "<div class='Section__title'>Lag Switches</div><div class='Section'>"
	html += "Disable deadmob <u title='Movement with keyboard'>keyLoop</u> (except staff): <a href='?_src_=holder;change_lag_switch=[DISABLE_DEAD_KEYLOOP]'><b>[SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] ? "On" : "Off"]</b></a><br>"
	html += "Disable ghost zoom: <a href='?_src_=holder;change_lag_switch=[DISABLE_GHOST_ZOOM]'><b>[SSlag_switch.measures[DISABLE_GHOST_ZOOM] ? "On" : "Off"]</b></a><br><br>"
	html += "Measures below can be bypassed with a <u title='TRAIT_BYPASS_MEASURES'>special trait</u><br>"
	html += "Slowmode say/me verbs: <a href='?_src_=holder;change_lag_switch=[SLOWMODE_IC_CHAT]'><b>[SSlag_switch.measures[SLOWMODE_IC_CHAT] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to speaker</span><br>"
	html += "Disable runechat: <a href='?_src_=holder;change_lag_switch=[DISABLE_RUNECHAT]'><b>[SSlag_switch.measures[DISABLE_RUNECHAT] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to speaker</span><br>"
	html += "Disable examine icons: <a href='?_src_=holder;change_lag_switch=[DISABLE_BICON]'><b>[SSlag_switch.measures[DISABLE_BICON] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to examiner</span><br>"
	html += "Disable parallax: <a href='?_src_=holder;change_lag_switch=[DISABLE_PARALLAX]'><b>[SSlag_switch.measures[DISABLE_PARALLAX] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to character</span><br>"
	html += "Disable footsteps sounds: <a href='?_src_=holder;change_lag_switch=[DISABLE_FOOTSTEPS]'><b>[SSlag_switch.measures[DISABLE_FOOTSTEPS] ? "On" : "Off"]</b></a> - <span style='font-size:80%'>trait applies to character</span>"
	html += "</div>"

	html += "<div class='Section__title bgbad'>Dangerous Zone</div><div class='Section'>"
	html += "<a class='[SSdemo.can_fire ? "bgbad" : "bggrey"]' href='?_src_=holder;lag_switch_special=STOP_DEMO'>DISABLE DEMO</a>"

	// not sure if we need it here, without own subsystem it will be awfully bad
	html += "<a class='[SSair.stop_airnet_processing ? "bgbad" : "bggrey"]' href='?_src_=holder;lag_switch_special=STOP_AIRNET'>DISABLE AIRNET</a>"
	html += "<a class='[SSmachines.stop_powernet_processing ? "bgbad" : "bggrey"]' href='?_src_=holder;lag_switch_special=STOP_POWERNET'>DISABLE POWERNET</a>"
	html += "</div>"

	var/datum/browser/popup = new(usr, "lag_switch_panel", "Lag Switch Panel", 440, 540)
	popup.set_content(html)
	popup.open()

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, reply = null, mentor_pm = FALSE)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(isclient(whom))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return "<b>(*not an mob*)</b>"
	switch(detail)
		if(0)
			return "<b>[key_name(C, link, name, 0, reply, mentor_pm)]</b>"
		if(1)
			return "<b>[key_name(C, link, name, 1, reply, mentor_pm)](<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)</b>"
		if(2)
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, 1, reply, mentor_pm)](<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=[ref_mob]'>JMP</A>) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>)</b>"



//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/living/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_ADMIN,0))
		return 0

	if (!frommob.ckey)
		return 0

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = tgui_alert(usr, question, "Place ghost in control of mob?", list("Yes", "No"))
	if (ask != "Yes")
		return 1

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1

	tomob.ghostize(can_reenter_corpse = FALSE)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	feedback_add_details("admin_verb","CGD")

	tomob.ckey = frommob.ckey
	qdel(frommob)

	return 1

/**********************Administration Shuttle**************************/

var/global/admin_shuttle_location = 0 // 0 = centcom 13, 1 = station

/proc/move_admin_shuttle()
	var/area/fromArea
	var/area/toArea
	var/static/moving = FALSE

	if(moving)
		return
	moving = TRUE

	if (admin_shuttle_location == 1)
		fromArea = locate(/area/shuttle/administration/station)
		toArea = locate(/area/shuttle/administration/centcom)

		SSshuttle.undock_act(fromArea)
		SSshuttle.undock_act(/area/station/hallway/secondary/entry, "arrival_admin")
	else
		fromArea = locate(/area/shuttle/administration/centcom)
		toArea = locate(/area/shuttle/administration/station)

		SSshuttle.undock_act(fromArea)
		SSshuttle.undock_act(/area/centcom/specops, "centcomm_admin")

	fromArea.move_contents_to(toArea)

	if (admin_shuttle_location)
		admin_shuttle_location = 0

		SSshuttle.dock_act(toArea)
		SSshuttle.dock_act(/area/centcom/specops, "centcomm_admin")
	else
		admin_shuttle_location = 1

		SSshuttle.dock_act(toArea)
		SSshuttle.dock_act(/area/station/hallway/secondary/entry, "arrival_admin")

	moving = FALSE

/**********************Centcom Ferry**************************/

var/global/ferry_location = 0 // 0 = centcom , 1 = station

/proc/move_ferry()
	var/area/fromArea
	var/area/toArea
	var/static/moving = FALSE

	if(moving)
		return
	moving = TRUE

	if (ferry_location == 1)
		fromArea = locate(/area/shuttle/transport1/station)
		toArea = locate(/area/shuttle/transport1/centcom)

		SSshuttle.undock_act(fromArea)
		SSshuttle.undock_act(/area/station/hallway/secondary/entry, "arrival_ferry")
	else
		fromArea = locate(/area/shuttle/transport1/centcom)
		toArea = locate(/area/shuttle/transport1/station)

		SSshuttle.undock_act(fromArea)
		SSshuttle.undock_act(/area/centcom/evac, "centcomm_ferry")

	fromArea.move_contents_to(toArea)

	if (ferry_location)
		ferry_location = 0

		SSshuttle.dock_act(toArea)
		SSshuttle.dock_act(/area/centcom/evac, "centcomm_ferry")
	else
		ferry_location = 1

		SSshuttle.dock_act(toArea)
		SSshuttle.dock_act(/area/station/hallway/secondary/entry, "arrival_ferry")

	moving = FALSE

/**********************Alien ship**************************/

var/global/alien_ship_location = 1 // 0 = base , 1 = mine

/proc/move_alien_ship()
	var/area/fromArea
	var/area/toArea
	if (alien_ship_location == 1)
		fromArea = locate(/area/shuttle/alien/mine)
		toArea = locate(/area/shuttle/alien/base)
	else
		fromArea = locate(/area/shuttle/alien/base)
		toArea = locate(/area/shuttle/alien/mine)
	fromArea.move_contents_to(toArea)
	if (alien_ship_location)
		alien_ship_location = 0
	else
		alien_ship_location = 1
	return
