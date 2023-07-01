// On Linux/Unix systems the line endings are LF, on windows it's CRLF, admins that don't use notepad++
// will get logs that are one big line if the system is Linux and they are using notepad.  This solves it by adding CR to every line ending
// in the logs.  ascii character 13 = CR

/var/global/log_end = world.system_type == UNIX ? ascii2text(13) : ""

//print an error message to world.log
#define ERROR(MSG) error("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/error(msg)
	world.log << "## ERROR: [msg][log_end]"

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [UNLINT(src)] usr: [usr].")
/proc/warning(msg)
	world.log << "## WARNING: [msg][log_end]"

//print a testing-mode debug message to world.log
/proc/testing(msg)
	world.log << "## TESTING: [msg][log_end]"

/proc/info(msg)
	world.log << "## INFO: [msg][log_end]"

/proc/round_log(msg)
	world.log << "\[[time_stamp()]][global.round_id ? "Round #[global.round_id]:" : ""] [msg][log_end]"
	global.game_log << "\[[time_stamp()]][global.round_id ? "Round #[global.round_id]:" : ""] [msg][log_end]"

/proc/log_href(text, say_type)
	if (config && config.log_hrefs)
		global.hrefs_log << "\[[time_stamp()]]: [text][log_end]"

/proc/log_admin(text)
	admin_log.Add(text)
	if (config.log_admin)
		global.game_log << "\[[time_stamp()]]ADMIN: [text][log_end]"

/proc/log_admin_private(text)
	admin_log.Add(text)
	if (config.log_admin)
		global.game_log << "\[[time_stamp()]]ADMINPRIVATE: [text][log_end]"

/proc/log_debug(text)
	if (config.log_debug)
		global.game_log << "\[[time_stamp()]]DEBUG: [text][log_end]"

	for(var/client/C as anything in admins)
		if(C.prefs.chat_toggles & CHAT_DEBUGLOGS)
			to_chat_debug(C, "DEBUG: [text]")

/proc/log_asset(text)
	if (config && config.log_asset)
		global.asset_log << "\[[time_stamp()]]ASSET: [text][log_end]"

/**
 * Appends a tgui-related log entry. All arguments are optional.
 */
/proc/log_tgui(user, message, context, datum/tgui_window/window, datum/src_object)
	if (!config.log_tgui)
		return

	var/entry = ""
	// Insert user info
	if(!user)
		entry += "<nobody>"
	else if(istype(user, /mob))
		var/mob/mob = user
		entry += "[mob.ckey] (as [mob] at [COORD(mob)])"
	else if(isclient(user))
		var/client/client = user
		entry += "[client.ckey]"
	// Insert context
	if(context)
		entry += " in [context]"
	else if(window)
		entry += " in [window.id]"
	// Resolve src_object
	if(!src_object && window && window.locked_by)
		src_object = window.locked_by.src_object
	// Insert src_object info
	if(src_object)
		entry += "\nUsing: [src_object.type] \ref[src_object]"
	// Insert message
	if(message)
		entry += "\n[message]"
	global.tgui_log << "\[[time_stamp()]]TGUI: [entry][log_end]"

/proc/log_game(text)
	if (config.log_game)
		global.game_log << "\[[time_stamp()]]GAME: [text][log_end]"

/proc/log_mode(text)
	if (config.log_game)
		global.game_log << "\[[time_stamp()]]MODE: [text][log_end]"

/proc/log_vote(text)
	if (config.log_vote)
		global.game_log << "\[[time_stamp()]]VOTE: [text][log_end]"

/proc/log_access(text)
	if (config && config.log_access)
		global.access_log << "\[[time_stamp()]]ACCESS: [text][log_end]"

/proc/log_say(text)
	if (config.log_say)
		global.game_log << "\[[time_stamp()]]SAY: [text][log_end]"

/proc/log_ooc(text)
	if (config.log_ooc)
		global.game_log << "\[[time_stamp()]]OOC: [text][log_end]"

/proc/log_whisper(text)
	if (config.log_whisper)
		global.game_log << "\[[time_stamp()]]WHISPER: [text][log_end]"

/proc/log_emote(text)
	if (config.log_emote)
		global.game_log << "\[[time_stamp()]]EMOTE: [text][log_end]"

/proc/log_attack(text)
	if (config.log_attack)
		global.game_log << "\[[time_stamp()]]ATTACK: [text][log_end]"

/proc/log_adminsay(text, say_type)
	admin_log.Add(text)
	if (config.log_adminchat)
		global.game_log << "\[[time_stamp()]][say_type]: [text][log_end]"

/proc/log_adminwarn(text)
	if (config.log_adminwarn)
		global.game_log << "\[[time_stamp()]]ADMINWARN: [text][log_end]"

/proc/log_pda(text)
	if (config.log_pda)
		global.game_log << "\[[time_stamp()]]PDA: [text][log_end]"

/proc/log_misc(text)
	global.game_log << "\[[time_stamp()]]MISC: [text][log_end]"

/proc/log_sql(text)
	world.log << "\[[time_stamp()]]SQL: [text][log_end]"
	if(config.log_sql_error)
		global.sql_error_log << "\[[time_stamp()]]SQL: [text][log_end]"

/proc/log_unit_test(text)
	world.log << "## UNIT_TEST ##: [text]"
	log_debug(text)

/proc/log_runtime(text)
	if (config && config.log_runtime)
		global.runtime_log << "\[[time_stamp()]] [text][log_end]"

/proc/log_initialization(text)
	var/static/preconfig_init_log = ""
	if (!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
		preconfig_init_log += "[text][log_end]"
		return

	if(config.log_initialization)
		if(length(preconfig_init_log))
			global.initialization_log << preconfig_init_log
			preconfig_init_log = null

		global.initialization_log << "[text][log_end]"

#ifdef REFERENCE_TRACKING
/proc/log_gc(text)
	global.gc_log << "\[[time_stamp()]] [text][log_end]"
	for(var/client/C in global.admins)
		if(C.prefs.chat_toggles & CHAT_DEBUGLOGS)
			to_chat(C, "GC DEBUG: [text]")
#endif

/proc/log_qdel(text)
	if (config.log_qdel)
		global.qdel_log << "[text][log_end]"

/atom/proc/log_investigate(message, subject)
	if(!message || !subject)
		return
	var/F = file("[global.log_investigate_directory]/[subject].html")
	F << "[time_stamp()] \ref[src] [COORD(src)] || [src] [strip_html_properly(message)]<br>[log_end]"

// Helper procs for building detailed log lines
/datum/proc/get_log_info_line()
	return "[src] ([type]) (\ref[src])"

/area/get_log_info_line()
	return "[..()] ([isnum(z) ? "[COORD(src)]" : "0,0,0"])"

/turf/get_log_info_line()
	return "[..()] [COORD(src)] ([loc ? loc.type : "NULL"])"

/atom/movable/get_log_info_line()
	var/turf/t = get_turf(src)
	return "[..()] ([t ? t : "NULL"]) ([t ? "[COORD(t)]" : "0,0,0"]) ([t ? t.type : "NULL"])"

/mob/get_log_info_line()
	return ckey ? "[..()] ([ckey])" : ..()

/proc/log_info_line(datum/D)
	if(isnull(D))
		return "*null*"
	if(islist(D))
		var/list/L = list()
		for(var/e in D)
			// Indexing on numbers just gives us the same number again in the best case and causes an index out of bounds runtime in the worst
			var/v = isnum(e) ? null : D[e]
			L += "[log_info_line(e)][v ? " - [log_info_line(v)]" : ""]"
		return "\[[jointext(L, ", ")]\]" // We format the string ourselves, rather than use json_encode(), because it becomes difficult to read recursively escaped "
	if(!istype(D))
		return json_encode(D)
	return D.get_log_info_line()

//pretty print a direction bitflag, can be useful for debugging.
/proc/print_dir(dir)
	var/list/comps = list()
	if(dir & NORTH) comps += "NORTH"
	if(dir & SOUTH) comps += "SOUTH"
	if(dir & EAST) comps += "EAST"
	if(dir & WEST) comps += "WEST"
	if(dir & UP) comps += "UP"
	if(dir & DOWN) comps += "DOWN"

	return get_english_list(comps, nothing_text="0", and_text="|", comma_text="|")

/proc/log_fax(text)
	if (config.log_fax)
		global.game_log << "\[[time_stamp()]]FAX: [text][log_end]"

/proc/datum_info_line(datum/D)
	if(!istype(D))
		return
	if(!istype(D, /mob))
		return "[D] ([D.type])"
	var/mob/M = D
	return "[M] ([M.ckey]) ([M.type])"

/proc/atom_loc_line(atom/A)
	if(!istype(A))
		return
	var/turf/T = get_turf(A)
	if(istype(T))
		return "[A.loc] [COORD(T)] ([A.loc.type])"
	else if(A.loc)
		return "[A.loc] (0, 0, 0) ([A.loc.type])"

//Print a list of antagonists to the server log
/proc/antagonist_announce()
	var/text = "ANTAG LIST:\n"
	var/objectives
	var/temprole
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in SSticker.minds)
		temprole = Mind.special_role
		objectives = ""
		if(temprole)							//if they are an antagonist of some sort.
			for(var/role in Mind.antag_roles)
				var/datum/role/R = Mind.antag_roles[role]
				if(R.objectives.objectives.len)
					for(var/datum/objective/O in R.objectives.GetObjectives())
						if(length(objectives))
							objectives += " | "
						objectives += "[O.explanation_text]"
					objectives = " \[[objectives]\]"

			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += "\n, [Mind.name]([Mind.key])[objectives]"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])[objectives]"

	//Now print them all into the log!
	if(total_antagonists.len)
		for(var/i in total_antagonists)
			text += "[i]s[total_antagonists[i]]."
	else
		text += "no antagonists this moment"

	log_game(text)
