//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
var/global/list/admin_verbs_default = list(
	/client/proc/deadmin_self,			//destroys our own admin datum so we can play as a regular player,
	/client/proc/hide_verbs,			//hides all our adminverbs,
	/client/proc/hide_most_verbs,		//hides all our hideable adminverbs,
	/client/proc/cmd_mentor_check_new_players,
	/datum/admins/proc/show_player_panel,	//shows an interface for individual players, with various links (links require additional flags,
	/client/proc/player_panel,
	)
var/global/list/admin_verbs_admin = list(
	/client/proc/player_panel_new,		//shows an interface for all players, with links to various panels,
	/client/proc/invisimin,				//allows our mob to go invisible/visible,
	/datum/admins/proc/toggleenter,		//toggles whether people can join the current game,
	/datum/admins/proc/toggleguests,	//toggles whether guests can join the current game,
	/datum/admins/proc/announce,		//priority announce something to all clients,
	/client/proc/colorooc,				//allows us to set a custom colour for everythign we say in ooc,
	/client/proc/admin_ghost,			//allows us to ghost/reenter body at will,
	/client/proc/toggle_view_range,		//changes how far we can see,
	/client/proc/cmd_admin_pm_context,	//right-click adminPM interface,
	/client/proc/cmd_admin_pm_panel,	//admin-pm list,
	/client/proc/cmd_admin_subtle_message,	//send an message to somebody as a 'voice in their head',
	/client/proc/cmd_admin_delete,		//delete an instance/object/mob/etc,
	/client/proc/cmd_admin_check_contents,	//displays the contents of an instance,
	/datum/admins/proc/access_news_network,	//allows access of newscasters,
	/client/proc/get_whitelist, 			//Whitelist,
	/client/proc/add_to_whitelist,
	/datum/admins/proc/whitelist_panel,
	/datum/admins/proc/customitems_panel,
	/datum/admins/proc/customitemspremoderation_panel,
	/datum/admins/proc/library_recycle_bin,
	/client/proc/jumptocoord,			//we ghost and jump to a coordinate,
	/client/proc/Getmob,				//teleports a mob to our location,
	/client/proc/Getkey,				//teleports a mob with a certain ckey to our location,
	/client/proc/Jump,
	/client/proc/jumptokey,				//allows us to jump to the location of a mob with a certain ckey,
	/client/proc/jumptomob,				//allows us to jump to a specific mob,
	/client/proc/jumptoturf,			//allows us to jump to a specific turf,
	/client/proc/admin_call_shuttle,	//allows us to call the emergency shuttle,
	/client/proc/admin_cancel_shuttle,	//allows us to cancel the emergency shuttle, sending it back to centcomm,
	/client/proc/cmd_admin_direct_narrate,	//send text directly to a player with no padding. Useful for narratives and fluff-text,
	/client/proc/cmd_admin_world_narrate,	//sends text to all players with no padding,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/check_ai_laws,			//shows AI and borg laws,
	/client/proc/check_antagonists,
	/client/proc/admin_memo,			//admin memo system. show/delete/write. +SERVER needed to delete admin memos of others,
	/client/proc/dsay,					//talk in deadchat using our ckey/fakekey,
	/client/proc/toggleprayers,			//toggles prayers on/off,
	/client/proc/toggle_hear_radio,		//toggles whether we hear the radio,
	/client/proc/secrets,
	/datum/admins/proc/toggleooc,		//toggles ooc on/off for everyone,
	/datum/admins/proc/togglelooc,		//toggles looc on/off for everyone,
	/datum/admins/proc/toggleoocdead,	//toggles ooc on/off for everyone who is dead,
	/datum/admins/proc/toggledsay,		//toggles dsay on/off for everyone,
	/client/proc/game_panel,			//game panel, allows to change game-mode etc,
	/client/proc/cmd_admin_say,			//admin-only ooc chat,
	/client/proc/free_slot,			//frees slot for chosen job,
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/toggleattacklogs,
	/client/proc/toggle_noclient_attacklogs,
	/client/proc/toggledebuglogs,
	/client/proc/toggleghostwriters,
	/client/proc/toggledrones,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/response_team, // Response Teams admin verb,
	/client/proc/toggle_antagHUD_use,
	/client/proc/toggle_antagHUD_restrictions,
	/client/proc/allow_character_respawn,	// Allows a ghost to respawn,
	/client/proc/aooc,
	/client/proc/empty_ai_core_toggle_latejoin,
	/client/proc/send_fax_message,
	/client/proc/debug_variables, 		//allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify,
	/client/proc/toggle_combo_hud, // Toggle all aviables huds, except mining hud,
	/client/proc/set_bwoink_sound, // affects only the admin that put it there,
	/client/proc/send_gods_message,
	/client/proc/metabolism_debug,
	)
var/global/list/admin_verbs_log = list(
	/client/proc/show_player_notes,
	/client/proc/getserverlogs,			//allows us to fetch server logs (diary) for other days,
	/client/proc/getcurrentlogs,			//allows us to fetch logs for other days,
	/client/proc/getlogsbyid,			   //allows us to fetch logs by round id,
	/client/proc/getoldlogs,			   //allows us to fetch logs by round id,
	/client/proc/investigate_show,		//various admintools for investigation. Such as a singulo grief-log,
	/client/proc/view_runtimes
	)
var/global/list/admin_verbs_variables = list(
	/client/proc/debug_variables,
	/client/proc/add_player_age,
	/client/proc/grand_guard_pass,
	/client/proc/mass_apply_status_effect,
	/client/proc/add_smartlight_preset,
	/client/proc/set_area_smartlight,
	/client/proc/set_level_light,
	/client/proc/debug_bloom,
)
var/global/list/admin_verbs_ban = list(
	/client/proc/unban_panel,
	/client/proc/stickybanpanel,
	)
var/global/list/admin_verbs_sounds = list(
	/client/proc/play_local_sound,
	/client/proc/play_global_sound,
	/client/proc/stop_server_sound,
	/client/proc/play_server_sound
	)
var/global/list/admin_verbs_fun = list(
	/client/proc/change_title_screen,
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/everyone_random,
	/client/proc/one_click_antag,
	/datum/admins/proc/toggle_aliens,
	/datum/admins/proc/toggle_space_ninja,
	/client/proc/send_space_ninja,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
//	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/set_global_ooc,
	/client/proc/editappear,
	/client/proc/roll_dices,
	/client/proc/epileptic_anomaly,
//	/client/proc/Noir_anomaly,
	/client/proc/epileptic_anomaly_cancel,
	/client/proc/achievement,
	/client/proc/toggle_AI_interact, //toggle admin ability to interact with machines as an AI,
	/client/proc/centcom_barriers_toggle,
	/client/proc/gateway_toggle,
	/client/proc/repaint_area_windows
	)
var/global/list/admin_verbs_spawn = list(
	/datum/admins/proc/spawn_atom,		//allows us to spawn instances,
	/client/proc/respawn_character,
	/datum/admins/proc/spawn_fluid_verb
	)
var/global/list/admin_verbs_server = list(
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/delay_end,
	/datum/admins/proc/toggleaban,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		//delete an instance/object/mob/etc,
	/client/proc/cmd_debug_del_all,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/datum/admins/proc/toggle_aliens,
	/datum/admins/proc/toggle_space_ninja,
	/datum/admins/proc/change_FH_control_type,
	/client/proc/toggle_random_events,
	/client/proc/nanomapgen_DumpImage,
	/client/proc/adminchangemap,
	/datum/admins/proc/show_lag_switch_panel,
	/datum/admins/proc/toggle_deathmatch_arena,
	)
var/global/list/admin_verbs_debug = list(
	/client/proc/edit_color_matrix,
	/client/proc/restart_controller,
	/client/proc/generate_round_scoreboard,
	/client/proc/save_statistics,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/toggle_profiler,
	/client/proc/Debug2,
	/client/proc/forceEvent,
	/client/proc/ZASSettings,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/cmd_debug_load_junkyard,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/cmd_debug_tog_vcounter,
	/client/proc/cmd_message_spam_control,
	/client/proc/investigate_show,
	/client/proc/reload_admins,
	/client/proc/reload_mentors,
	/client/proc/reload_config,
//	/client/proc/remake_distribution_map,
//	/client/proc/show_distribution_map,
	/client/proc/enable_debug_verbs,
	/*/client/proc/callproc,*/
//	/proc/machine_upgrade,
	/client/proc/toggledebuglogs,
	/client/proc/view_runtimes,
	/client/proc/getdebuglogsbyid,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_init_log,
	/client/proc/debugNatureMapGenerator,
	/datum/admins/proc/run_unit_test,
	/client/proc/event_manager_panel,
	/client/proc/generate_fulltile_window_placeholders,
	/client/proc/allow_browser_inspect,
	/client/proc/mc_show_all_toggle,
#ifdef REFERENCE_TRACKING
/client/proc/find_refs,
/client/proc/qdel_then_find_references,
/client/proc/qdel_then_if_fail_find_references,
#endif
	)
var/global/list/admin_verbs_possess = list(
	/proc/possess,
	/proc/release
	)
var/global/list/admin_verbs_permissions = list(
	/client/proc/edit_admin_permissions,
	/client/proc/library_debug_remove,
	/client/proc/library_debug_read,
	/client/proc/regisration_panic_bunker,
	/client/proc/host_announcements,
	/client/proc/add_round_admin,
	)
var/global/list/admin_verbs_rejuv = list(
	/client/proc/cmd_admin_rejuvenate,
	/client/proc/respawn_character
	)
var/global/list/admin_verbs_whitelist = list(
	/client/proc/get_whitelist, 			//Whitelist,
	/client/proc/add_to_whitelist,
	/datum/admins/proc/whitelist_panel,
	/datum/admins/proc/toggle_job_restriction
	)
var/global/list/admin_verbs_event = list(
	/client/proc/event_map_loader,
	/client/proc/admin_crew_salary,
	/client/proc/event_manager_panel,
	/client/proc/change_blobwincount,
	/client/proc/load_deathmatch_arena
	)

//verbs which can be hidden - needs work
var/global/list/admin_verbs_hideable = list(
	/client/proc/set_global_ooc,
	/datum/admins/proc/library_recycle_bin,
	/client/proc/deadmin_self,
//	/client/proc/deadchat,
	/client/proc/toggleprayers,
	/client/proc/toggle_hear_radio,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/client/proc/colorooc,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/client/proc/getserverlogs,
	/client/proc/getcurrentlogs,
	/client/proc/getlogsbyid,
	/client/proc/getoldlogs,
	/client/proc/investigate_show,
	/client/proc/view_runtimes,
	/client/proc/getdebuglogsbyid,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_check_contents,
	/datum/admins/proc/access_news_network,
	/client/proc/admin_call_shuttle,
	/client/proc/admin_cancel_shuttle,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/play_local_sound,
	/client/proc/play_global_sound,
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/get_whitelist, 			//Whitelist,
	/client/proc/add_to_whitelist,
	/datum/admins/proc/whitelist_panel,
	/datum/admins/proc/toggle_aliens,
	/datum/admins/proc/toggle_space_ninja,
	/client/proc/send_space_ninja,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
//	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/cmd_admin_add_random_ai_law,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/delay_end,
	/datum/admins/proc/toggleaban,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/restart_controller,
	/client/proc/generate_round_scoreboard,
	/client/proc/save_statistics,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/client/proc/cmd_admin_list_open_jobs,
//	/client/proc/callproc,
	/client/proc/toggle_profiler,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/startSinglo,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/cmd_debug_tog_vcounter,
	/client/proc/enable_debug_verbs,
	/client/proc/add_player_age,
	/client/proc/grand_guard_pass,
	/proc/possess,
	/proc/release
	)

/client/proc/add_admin_verbs()
	if(holder)
		verbs += admin_verbs_default
		if(holder.rights & R_BUILDMODE)
			verbs += /client/proc/togglebuildmodeself
		if(holder.rights & R_ADMIN)
			verbs += admin_verbs_admin
		if(holder.rights & R_BAN)
			verbs += admin_verbs_ban
		if(holder.rights & R_FUN)
			verbs += admin_verbs_fun
		if(holder.rights & R_SERVER)
			verbs += admin_verbs_server
		if(holder.rights & R_DEBUG)
			verbs += admin_verbs_debug
		if(holder.rights & R_POSSESS)
			verbs += admin_verbs_possess
		if(holder.rights & R_PERMISSIONS)
			verbs += admin_verbs_permissions
		if(holder.rights & R_STEALTH)
			verbs += /client/proc/stealth
		if(holder.rights & R_REJUVINATE)
			verbs += admin_verbs_rejuv
		if(holder.rights & R_SOUNDS)
			verbs += admin_verbs_sounds
		if(holder.rights & R_SPAWN)
			verbs += admin_verbs_spawn
		if(holder.rights & R_WHITELIST)
			verbs += admin_verbs_whitelist
		if(holder.rights & R_EVENT)
			verbs += admin_verbs_event
		if(holder.rights & R_LOG)
			verbs += admin_verbs_log
		if(holder.rights & R_VAREDIT)
			verbs += admin_verbs_variables

		if(holder.rights & R_ADMIN)
			control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

/client/proc/remove_admin_verbs()
	verbs.Remove(
		admin_verbs_default,
		/client/proc/togglebuildmodeself,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_fun,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_possess,
		admin_verbs_permissions,
		/client/proc/stealth,
		admin_verbs_rejuv,
		admin_verbs_sounds,
		admin_verbs_spawn,
		admin_verbs_whitelist,
		admin_verbs_event,
		admin_verbs_log,
		admin_verbs_variables,
		debug_verbs
		)

/client/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"

	verbs.Remove(/client/proc/hide_most_verbs, admin_verbs_hideable)
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Most of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","HMV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	verbs -= /client/proc/show_verbs
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!





/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	if(!holder)	return
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		ghost.can_reenter_corpse = TRUE
		ghost.reenter_corpse()

		feedback_add_details("admin_verb","P") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>")
	else
		//ghostize
		var/mob/body = mob
		body.ghostize(can_reenter_corpse = TRUE)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		feedback_add_details("admin_verb","O") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(holder && mob)
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, "<span class='warning'><b>Invisimin off. Invisibility reset.</b></span>")
			mob.alpha = max(mob.alpha + 100, 255)
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			to_chat(mob, "<span class='notice'><b>Invisimin on. You are now as invisible as a ghost.</b></span>")
			mob.alpha = max(mob.alpha - 100, 0)


/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if(holder)
		holder.player_panel_old()
	feedback_add_details("admin_verb","PP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/player_panel_new()
	set name = "Player Panel New"
	set category = "Admin"
	if(holder)
		holder.player_panel_new()
	feedback_add_details("admin_verb","PPN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
	feedback_add_details("admin_verb","CHA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if(!holder)
		return
	if(!config.sql_enabled)
		to_chat(usr, "<span class='notice'>SQL database is disabled. Setup it or use native Byond bans.</span>")
		return

	holder.DB_ban_panel()
	feedback_add_details("admin_verb","UBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if(holder)
		holder.Game()
	feedback_add_details("admin_verb","GP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	feedback_add_details("admin_verb","S") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/colorooc()
	set category = "OOC"
	set name = "Set Admin OOC Color"
	if(!holder)
		return
	if(!config.allow_admin_ooccolor)
		to_chat(usr, "<span class='warning'>Currently disabled by config.</span>")
	var/new_aooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color|null
	if(new_aooccolor)
		prefs.aooccolor = normalize_color(new_aooccolor)
		prefs.save_preferences()
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"

	if(!holder || !(holder.rights & R_STEALTH))
		return

	if(holder.fakekey)
		holder.fakekey = null
		mob.invisibility = initial(mob.invisibility)
		mob.alpha = 127//initial(mob.alpha)
		mob.name = initial(mob.name)
	else
		var/new_key = ckeyEx(input("Enter your desired display name.", "Fake Key", key) as text|null)
		if(!new_key)	return
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		holder.fakekey = new_key
		mob.invisibility = INVISIBILITY_MAXIMUM + 1 //JUST IN CASE
		mob.alpha = 0 //JUUUUST IN CASE
		mob.name = " "
	log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
	feedback_add_details("admin_verb","SM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/warn(warned_ckey)
	if(!check_rights(R_ADMIN))
		return

	warned_ckey = ckey(warned_ckey)

	var/reason = input(usr, "Reason?", "Warn Reason","") as text|null

	if(!warned_ckey || !reason)
		return

	notes_add(warned_ckey, "ADMINWARN: " + reason, admin_key = src.ckey, secret = 0)

	var/client/C = directory[warned_ckey]
	reason = sanitize(reason)

	if(C)
		to_chat(C, "<span class='alert'><span class='reallybig bold'>You have been formally warned by an administrator.</span><br>Reason: [reason].</span>")

	log_admin("[src.key] has warned [warned_ckey] with reason: [reason]")
	message_admins("[key_name_admin(src)] has warned [C ? key_name_admin(C) : warned_ckey] with reason: [reason].")

	feedback_add_details("admin_verb","WARN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mass_apply_status_effect()
	set category = "Special Verbs"
	set name = "Mass Apply Status Effect"
	set desc = "Apply a status effect to every mob."

	var/list/params = admin_spawn_status_effect(usr)
	if(params)
		if(tgui_alert(usr, "Confirm applying the status effect to every mob?",, list("Yes", "No")) == "Yes")
			for(var/mob/living/L in global.living_list)
				L.apply_status_effect(arglist(params))

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Special Verbs"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Cap Bomb", "Nuke", "Custom Bomb", "Cancel")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3)
		if("Medium Bomb")
			explosion(epicenter, 2, 4, 6)
		if("Big Bomb")
			explosion(epicenter, 3, 6, 9)
		if("Cap Bomb")
			explosion(epicenter, SSexplosions.MAX_EX_DEVESTATION_RANGE, SSexplosions.MAX_EX_HEAVY_RANGE, SSexplosions.MAX_EX_LIGHT_RANGE)
		if("Nuke")
			if(tgui_alert(usr, "This will break things terribly, are you sure?", "Confirm", list("Ok", "Cancel")) == "Cancel")
				return
			SSticker.station_explosion_detonation(epicenter)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			var/flash_range = input("Flash range (in tiles):") as num
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		if("Cancel")
			return 0
	log_admin("[ckey] created an admin explosion ([choice]) at [epicenter.loc].")
	message_admins("<span class='notice'>[ckey] created an admin explosion ([choice]) at [epicenter.loc].</span>")
	feedback_add_details("admin_verb","DB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in mob_list) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."
	var/list/spell_names = list()
	for(var/v in spells)
	//	"[/obj/effect/proc_holder/spell]/" 30 symbols ~Intercross21
		spell_names.Add(copytext("[v]", 31, 0))
	var/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_names
	if(!S) return
	var/path = text2path("/obj/effect/proc_holder/spell/[S]")
	T.AddSpell(new path)
	feedback_add_details("admin_verb","GS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("<span class='notice'>[key_name_admin(usr)] gave [key_name(T)] the spell [S].</span>")

/client/proc/give_disease2(mob/T as mob in mob_list) // -- Giacom
	set category = "Fun"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."

	var/datum/disease2/disease/D = new /datum/disease2/disease()

	var/disease_type = input("Is this a lesser or greater disease?", "Give Disease") in list("Lesser", "Greater", "Custom")
	var/greater = (disease_type == "Greater")

	if(disease_type == "Custom")
		D.uniqueID = rand(0,10000)
		D.antigen |= text2num(pick(ANTIGENS))
		D.antigen |= text2num(pick(ANTIGENS))

		var/list/datum/disease2/effect/possible_effects = list()
		for(var/e in subtypesof(/datum/disease2/effect))
			var/datum/disease2/effect/f = new e
			if (f.level > 4) //we don't want such strong effects
				continue
			if (f.level < 1)
				continue
			possible_effects += f

		while(TRUE)
			var/command = input("Disease menu, ([D.effects.len] symptoms)", "Make custom disease") in list("Add symptom", "Remove symptom", "Done")
			if(command == "Add symptom" && D.effects.len < D.max_symptoms)
				if(!possible_effects.len)
					continue
				var/effect = input("Add symptom", "Select symptom") as null|anything in possible_effects
				if(!effect)
					continue
				possible_effects -= effect
				var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
				holder.effect = effect
				holder.name = holder.effect.name
				holder.chance = rand(holder.effect.chance_minm, holder.effect.chance_maxm)
				D.addeffect(holder)
			if(command == "Remove symptom" && D.effects.len > 0)
				var/datum/disease2/effectholder/holder = input("Remove symptom", "Select symptom to remove") as null|anything in D.effects
				if(!holder)
					continue
				possible_effects += holder.effect
				D.effects -= holder
				qdel(holder)

			if(command == "Done")
				break
		disease_type = "[disease_type] ([jointext(D.effects, ", ")])"
	else
		D.makerandom(greater, spread_vector = DISEASE_SPREAD_AIRBORNE)
		if (!greater)
			D.infectionchance = 1

	D.infectionchance = input("How virulent is this disease? (1-100)", "Give Disease", D.infectionchance) as num

	infect_virus2(T,D,1)

	feedback_add_details("admin_verb","GD2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] a [disease_type] disease2 with infection chance [D.infectionchance].")
	message_admins("[key_name_admin(usr)] gave [key_name(T)] a [disease_type] disease2 with infection chance [D.infectionchance].")

/* disabled because this is not a sound but a hearable message, and also very hard to use since you need to choose an item from a huge list and not a view at least.
   so, this proc needs rewrite to be a verb per object or something like that and also better name because it can be named more obvious than using desc.
   also "in world"
/client/proc/make_sound(obj/O in world) // -- TLE
	set category = "Special Verbs"
	set name = "Make Sound"
	set desc = "Display a message to everyone who can hear the target."
	if(O)
		var/message = sanitize(input("What do you want the message to be?", "Make Sound") as text|null)
		if(!message)
			return
		for (var/mob/V in hearers(O))
			V.show_messageold(message, 2)
		log_admin("[key_name(usr)] made [O] at [COORD(O)]. make a sound")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [O] at [COORD(O)] (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[O.x];Y=[O.y];Z=[O.z]'>JMP</a>) make a sound</span>")
		feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
*/

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Special Verbs"
	if(!mob || !(holder.rights & R_BUILDMODE))
		return

	togglebuildmode(mob)
	feedback_add_details("admin_verb","TBMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/change_title_screen()
	set name = "Title Screen: Change"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	log_admin("[key_name(usr)] try change the title screen.")
	message_admins("[key_name_admin(usr)] try change the title screen.")
	feedback_add_details("admin_verb", "CTS")

	switch(tgui_alert(usr, "How change Title Screen?", "Title Screen", list("Change", "Reset", "Cancel")))
		if("Change")
			var/file = input(usr) as icon|null
			if(!file)
				return
			change_lobbyscreen(file)
		if("Reset")
			change_lobbyscreen()
		if("Cancel")
			return

	for(var/mob/dead/new_player/N as anything in new_player_list)
		N.show_titlescreen()

/client/proc/object_talk(msg as text) // -- TLE
	set category = "Special Verbs"
	set name = "oSay"
	set desc = "Display a message to everyone who can hear the target."
	if(mob.control_object)
		if(!msg)
			return
		mob.control_object.audible_message("<b>[mob.control_object.name]</b> says: \"[msg]\"")
	feedback_add_details("admin_verb","OT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/readmin_self()
	set name = "Re-admin self"
	set category = "Admin"

	if(deadmin_holder)
		deadmin_holder.reassociate()
		log_admin("[key_name(usr)] re-admined themself.")
		message_admins("[key_name_admin(usr)] re-admined themself.")
		to_chat(src, "<span class='interface'>You now have the keys to control the planet, or at least a small space station.</span>")
		verbs -= /client/proc/readmin_self
		feedback_add_details("admin_verb","RAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/deadmin_self()
	set name = "De-admin self"
	set category = "Admin"

	if(!holder)
		return

	if(tgui_alert(usr, "Confirm self-deadmin for the round?",, list("Yes","No")) == "Yes")
		if(has_antag_hud())
			toggle_combo_hud()

		log_admin("[key_name(usr)] deadmined themself.")
		message_admins("[key_name_admin(usr)] deadmined themself.")
		deadmin()
		to_chat(src, "<span class='interface'>You are now a normal player.</span>")
		verbs += /client/proc/readmin_self
		feedback_add_details("admin_verb","DAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.log_hrefs)
			config.log_hrefs = 0
			to_chat(src, "<b>Stopped logging hrefs</b>")
		else
			config.log_hrefs = 1
			to_chat(src, "<b>Started logging hrefs</b>")

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"
	if(holder)
		holder.output_ai_laws()

//---- bs12 verbs ----

/client/proc/mod_panel()
	set name = "Moderator Panel"
	set category = "Admin"
/*	if(holder)
		holder.mod_panel()*/
//	feedback_add_details("admin_verb","MP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/editappear(mob/living/carbon/human/M as mob in human_list)
	set name = "Edit Appearance"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	if(!ishuman(M))
		to_chat(usr, "<span class='warning'>You can only do this to humans!</span>")
		return
	switch(tgui_alert(usr, "Are you sure you wish to edit this mob's appearance? Skrell, Unathi, Vox and Tajaran can result in unintended consequences.",, list("Yes","No")))
		if("No")
			return
	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_skin = input("Please select body color. This is for Tajaran, Unathi, and Skrell only!", "Character Generation") as color
	if(new_skin)
		M.r_skin = hex2num(copytext(new_skin, 2, 4))
		M.g_skin = hex2num(copytext(new_skin, 4, 6))
		M.b_skin = hex2num(copytext(new_skin, 6, 8))

	var/new_tone = input("Выберите цвет кожи", "Создание персонажа") in global.skin_tones_by_ru_name
	var/datum/skin_tone/T = global.skin_tones_by_ru_name[new_tone]
	M.s_tone = T.name

	var/new_gender = tgui_alert(usr, "Please select gender.", "Character Generation", list("Male", "Female"))
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE

	// hair
	var/new_hstyle = input(usr, "Select a hair style", "Grooming")  as null|anything in get_valid_styles_from_cache(hairs_cache, M.get_species(), M.gender)
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Select a facial hair style", "Grooming")  as null|anything in get_valid_styles_from_cache(facial_hairs_cache, M.get_species(), M.gender)
	if(new_fstyle)
		M.f_style = new_fstyle

	M.update_body(update_preferences = TRUE)
	M.check_dna(M)

/client/proc/show_player_notes(key as text)
	set name = "Show Player Notes"
	set category = "Logs"
	holder?.show_player_notes(key)

/client/proc/free_slot()
	set name = "Free Job Slot"
	set category = "Admin"
	if(holder)
		var/list/jobs = list()
		for (var/datum/job/J as anything in SSjob.active_occupations)
			if (J.current_positions >= J.total_positions && J.total_positions != -1)
				jobs += J.title
		if (!jobs.len)
			to_chat(usr, "There are no fully staffed jobs.")
			return
		var/job = input("Please select job slot to free", "Free job slot")  as null|anything in jobs
		if (job)
			SSjob.FreeRole(job)

/client/proc/toggle_combo_hud()
	set name = "Toggle Combo HUD"
	set desc = "Toggles the Admin Combo HUD (antag, sci, med, eng)"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	if(isobserver(usr))
		var/mob/dead/observer/O = usr
		if(O.data_hud)
			to_chat(usr, "Please disable combo-HUDs in the ghost tab.")
			return

	var/adding_hud = !has_antag_hud()

	for(var/hudtype in list(DATA_HUD_SECURITY, DATA_HUD_MEDICAL_ADV, DATA_HUD_DIAGNOSTIC, DATA_HUD_HOLY)) // add data huds
		var/datum/atom_hud/H = global.huds[hudtype]
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)
	for(var/hud in get_all_antag_huds())
		var/datum/atom_hud/antag/H = hud
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)

	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.update_sight()

	to_chat(usr, "You toggled your admin combo HUD [adding_hud ? "ON" : "OFF"].")
	message_admins("[key_name_admin(usr)] toggled their admin combo HUD [adding_hud ? "ON" : "OFF"].")
	log_admin("[key_name(usr)] toggled their admin combo HUD [adding_hud ? "ON" : "OFF"].")

/client/proc/has_antag_hud()
	var/datum/atom_hud/A = global.huds[ANTAG_HUD_TRAITOR]
	return A.hudusers[mob]

/client/proc/toggleattacklogs()
	set name = "Toggle Attack Log Messages"
	set category = "Preferences"

	prefs.chat_toggles ^= CHAT_ATTACKLOGS
	prefs.save_preferences()
	to_chat(src, "You now [(prefs.chat_toggles & CHAT_ATTACKLOGS) ? "will" : "won't"] get attack log messages.")
	feedback_add_details("admin_verb","TALM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_noclient_attacklogs()
	set name = "Toggle No Client Attack Log Messages"
	set category = "Preferences"

	prefs.chat_toggles ^= CHAT_NOCLIENT_ATTACK
	prefs.save_preferences()
	to_chat(src, "You now [(prefs.chat_toggles & CHAT_NOCLIENT_ATTACK) ? "will" : "won't"] get attack log messages for mobs that don't have a client.")
	feedback_add_details("admin_verb","TNCALM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleghostwriters()
	set name = "Toggle ghost writers"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.cult_ghostwriter)
			config.cult_ghostwriter = 0
			to_chat(src, "<b>Disallowed ghost writers.</b>")
			message_admins("Admin [key_name_admin(usr)] has disabled ghost writers.")
		else
			config.cult_ghostwriter = 1
			to_chat(src, "<b>Enabled ghost writers.</b>")
			message_admins("Admin [key_name_admin(usr)] has enabled ghost writers.")

/client/proc/toggledrones()
	set name = "Toggle maintenance drones"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.allow_drone_spawn)
			config.allow_drone_spawn = 0
			to_chat(src, "<b>Disallowed maint drones.</b>")
			message_admins("Admin [key_name_admin(usr)] has disabled maint drones.")
		else
			config.allow_drone_spawn = 1
			to_chat(src, "<b>Enabled maint drones.</b>")
			message_admins("Admin [key_name_admin(usr)] has enabled maint drones.")

/client/proc/toggledebuglogs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	prefs.chat_toggles ^= CHAT_DEBUGLOGS
	prefs.save_preferences()
	to_chat(src, "You now [(prefs.chat_toggles & CHAT_DEBUGLOGS) ? "will" : "won't"] get debug log messages.")
	feedback_add_details("admin_verb","TDLM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/man_up(mob/T as mob in player_list)
	set category = "Fun"
	set name = "Man Up"
	set desc = "Tells mob to man up and deal with it."

	to_chat(T, "<span class='notice'><b><font size=3>Man up and deal with it.</font></b></span>")
	to_chat(T, "<span class='notice'>Move on.</span>")
	T.playsound_local(null, 'sound/voice/ManUp1.ogg', VOL_ADMIN, vary = FALSE, ignore_environment = TRUE)

	log_admin("[key_name(usr)] told [key_name(T)] to man up and deal with it.")
	message_admins("<span class='notice'>[key_name_admin(usr)] told [key_name(T)] to man up and deal with it.</span>")

/client/proc/global_man_up()
	set category = "Fun"
	set name = "Man Up Global"
	set desc = "Tells everyone to man up and deal with it."

	for (var/mob/T in player_list)
		to_chat(T, "<br><center><span class='notice'><b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.</span></center><br>")
		T.playsound_local(null, 'sound/voice/ManUp1.ogg', VOL_ADMIN, vary = FALSE, ignore_environment = TRUE)

	log_admin("[key_name(usr)] told everyone to man up and deal with it.")
	message_admins("<span class='notice'>[key_name_admin(usr)] told everyone to man up and deal with it.</span>")
	mob.eject_from_wall()

/client/proc/achievement()
	set name = "Give Achievement"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	var/achoice = "Cancel"

	if(!player_list.len)
		to_chat(usr, "player list is empty!")
		return

	var/mob/winner = input("Who's a winner?", "Achievement Winner") in player_list
	var/name = sanitize(input("What will you call your achievement?", "Achievement Winner", "New Achievement"))
	var/desc = sanitize(input("What description will you give it?", "Achievement Description", "You Win"))

	if(isliving(winner))
		achoice = tgui_alert(usr, "Give our winner his own trophy?","Achievement Trophy", list("Confirm","Cancel"))

	var/glob = tgui_alert(usr, "Announce the achievement globally? (Beware! Ruins immersion!)","Last Question", list("No!","Yes!"))

	if(achoice == "Confirm")
		var/obj/item/weapon/reagent_containers/food/drinks/golden_cup/C = new(get_turf(winner))
		C.name = name
		C.desc = desc
		winner.put_in_hands(C)
		winner.update_icons()
	else
		to_chat(winner, "<span class='danger'>You win [name]! [desc]</span>")

	var/icon/cup = icon('icons/obj/drinks.dmi', "golden_cup")

	if(glob == "No!")
		winner.playsound_local(null, 'sound/misc/achievement.ogg', VOL_ADMIN, vary = FALSE, ignore_environment = TRUE)
	else
		for(var/mob/M in player_list)
			M.playsound_local(null, 'sound/misc/achievement.ogg', VOL_ADMIN, vary = FALSE, ignore_environment = TRUE)
		to_chat(world, "<span class='danger'>[bicon(cup)] <b>[winner.name]</b> wins \"<b>[name]</b>\"!</span>")

	to_chat(winner, "<span class='danger'>Congratulations!</span>")

	SSStatistics.add_achievement(winner.key, winner.name, name, desc)

/client/proc/aooc()
	set category = "Admin"
	set name = "Antag OOC"

	if(!check_rights(R_ADMIN))
		return

	var/msg = sanitize(input(usr, "", "Antag OOC") as text)
	if(!msg)	return

	var/display_name = src.key
	if(holder && holder.fakekey)
		display_name = holder.fakekey

	for(var/mob/M in player_list)
		if((isanyantag(M)) || (M.client && M.client.holder))
			to_chat(M, "<span class='antagooc'><span class='prefix'>Antag-OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span>")

	log_ooc("Antag-OOC: [key_name(src)] : [msg]")

/client/proc/toggle_AI_interact()
	set name = "Toggle Admin AI Interact"
	set category = "Fun"
	set desc = "Allows you to interact with most machines as an AI would as a ghost"

	AI_Interact = !AI_Interact
	machine_interactive_ghost = AI_Interact
	log_admin("[key_name(usr)] has [AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] has [AI_Interact ? "activated" : "deactivated"] their AI interaction")

/client/proc/admin_crew_salary()
	set name = "Salary"
	set category = "Event"
	if(holder)
		holder.change_crew_salary()
	feedback_add_details("admin_verb","Salary") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/change_blobwincount()
	set name = "Change Blobs to Win"
	set category = "Event"
	if(holder)
		var/datum/faction/blob_conglomerate/conglomerate = find_faction_by_type(/datum/faction/blob_conglomerate)
		if(!conglomerate)
			return

		var/new_count =  input(src, "Enter new Blobs count to Win", "New Blobwincount", conglomerate.blobwincount) as num|null
		if(new_count)
			conglomerate.blobwincount = new_count
			log_admin("[key_name(usr)] changed blobwincount to [conglomerate.blobwincount]")
			message_admins("[key_name_admin(usr)] changed blobwincount to [conglomerate.blobwincount]")
			feedback_add_details("admin_verb","Blobwincount") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/repaint_area_windows()
	set category = "Fun"
	set name = "Repaint Area Windows"

	if(!check_rights(R_FUN))
		return

	if(!SSstation_coloring.initialized)
		to_chat(usr, "<span class='warning'>Subsystem has not finished initializing, please wait.</span>")
		return

	var/new_color = input(src, "Please select new colour.", "Windows colour") as color|null

	if(!new_color)
		return

	var/area/A = get_area(usr)
	if(!A)
		return

	SSstation_coloring.color_area_objects(list(A), new_color)

	log_admin("[key_name(src)] repainted the windows [new_color] in \the [A]")
	message_admins("[key_name(src)] repainted the windows [new_color] in \the [A]")

//////////////////////////////
// Map loader
//////////////////////////////

/client/proc/event_map_loader() // rename
	set category = "Event"
	set name = "Event map loader"
	if(!check_rights(R_EVENT))
		return

	var/list/AllowedMaps = list()

	var/list/Lines = file2list("maps/event_map_list.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue
		t = trim(t)
		if (length(t) == 0)
			continue
		else if (t[1] == "#")
			continue
		var/pos = findtext(t, " ")
		var/name = null
		if (pos)
			// No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		//	value = copytext(t, pos + 1)
		else
			// No, don't do lowertext here, that breaks paths on linux
			name = t
		if (!name)
			continue

		AllowedMaps.Add(name)


	AllowedMaps += "--CANCEL--"

	var/choice = input("Select a map", , "CANCEL") in AllowedMaps
	if(choice == "--CANCEL--") return

	var/linkage = input("Linkage", , "None") in list(SELFLOOPING, CROSSLINKED, "None")

	if(linkage == "None")
		linkage = UNAFFECTED

	message_admins("[key_name_admin(src)] started loading event-map [choice]")
	log_admin("[key_name(src)] started loading event-map [choice]")

	if(maploader.load_new_z_level(choice, list(ZTRAIT_AWAY = TRUE, ZTRAIT_LINKAGE = linkage)))//, load_speed = 100)
		message_admins("[key_name_admin(src)] loaded event-map [choice], zlevel [world.maxz], linkage [linkage ? linkage : "not set"]")
		log_admin("[key_name(src)] loaded event-map [choice], zlevel [world.maxz], linkage [linkage ? linkage : "not set"]")
	else
		message_admins("[key_name_admin(src)] failed to load event-map [choice].")

//////////////////////////////
// Gateway
//////////////////////////////

/client/proc/gateway_toggle()
	set category = "Event"
	set name = "Toggle Station Gateway"

	if(!check_rights(R_FUN))
		return

	config.gateway_enabled = !config.gateway_enabled

	log_admin("[key_name(src)] toggle [config.gateway_enabled ? "on" : "off"] station gateway")
	message_admins("[key_name(src)] toggle [config.gateway_enabled ? "on" : "off"] station gateway")

//////////////////////////////
// Velocity\Centcomm barriers
//////////////////////////////
var/global/centcom_barriers_stat = 1

/client/proc/centcom_barriers_toggle()
	set category = "Event"
	set name = "Centcom Barriers Toggle"

	centcom_barriers_stat = !centcom_barriers_stat

	if(!check_rights(R_FUN))
		return

	for(var/obj/effect/landmark/trololo/L as anything in landmarks_list["Rickroll"])
		L.active = centcom_barriers_stat
	for(var/obj/structure/centcom_barrier/B as anything in centcom_barrier_list)
		B.density = centcom_barriers_stat

	log_admin("[key_name(src)] switched [centcom_barriers_stat? "on" : "off"] centcomm barriers")
	message_admins("[key_name_admin(src)] switched [centcom_barriers_stat? "on" : "off"] centcomm barriers")

/obj/effect/landmark/trololo
	name = "Rickroll"
	var/message = "<i><span class='notice'>It's not the door you're looking for...</span></i>"
	var/active = 1

/obj/effect/landmark/trololo/Crossed(atom/movable/AM)
	. = ..()
	if(!active) return
	to_chat(usr, "<span class='notice'><b><font size=3>Never gonna give you up.</font></b></span>")

/obj/structure/centcom_barrier
	name = "Invisible wall"
	anchored = TRUE
	density = TRUE
	invisibility = 101
	icon = 'icons/hud/screen1.dmi'
	icon_state = "x3"

/obj/structure/centcom_barrier/atom_init()
	. = ..()
	centcom_barrier_list += src

/obj/structure/centcom_barrier/Destroy()
	centcom_barrier_list -= src
	return ..()

/client/proc/load_deathmatch_arena()
	set category = "Event"
	set name = "Load Deathmatch Arena"

	var/list/arenas = list()

	for(var/i in subtypesof(/datum/map_template/post_round_arena))
		var/datum/map_template/post_round_arena/A = i
		arenas[A.name] = A

	var/choice = input("Select the arena") as null|anything in arenas
	if(!choice) return

	var/datum/map_template/post_round_arena/arena = arenas[choice]
	SSticker.load_arena_admin(arena)

	log_admin("[key_name(src)] load arena map [arena.name] - [arena.mappath]")
	message_admins("[key_name_admin(src)] load arena map [arena.name] - [arena.mappath]")

/client/proc/metabolism_debug()
	set category = "Debug"
	set name = "Debug Metabolism"

	if(!isliving(mob))
		return

	var/mob/living/L = mob
	L.metabolism_debug()
