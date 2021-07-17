SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = SS_WAIT_PANEL
	init_order = SS_INIT_STATPANELS
	priority = SS_PRIORITY_STATPANEL
	flags = SS_TICKER | SS_FIRE_IN_LOBBY
	var/list/currentrun = list()
	var/encoded_global_data
	var/mc_data_encoded // R_DEBUG
	var/mc_data_for_admins_encoded
	var/list/cached_images = list()

/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	if (!resumed)
		var/datum/map_config/cached = SSmapping.next_map_config
		var/list/global_data = list(
			"Round ID: [global.round_id ? global.round_id : "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Map: [SSmapping.config?.map_name || "Loading..."]",
			cached ? "Next Map: [cached.map_name]" : null,
		)
		encoded_global_data = url_encode(json_encode(global_data))
		src.currentrun = global.clients.Copy()
		mc_data_encoded = null
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--
		if(!target.statbrowser_ready)
			continue
		if(target.stat_tab == "Status")
			var/other_str = url_encode(json_encode(target.mob.get_status_tab_items()))
			target << output("[encoded_global_data];[other_str]", "statbrowser:update")
		if(!target.holder)
			target << output("", "statbrowser:remove_admin_tabs")
		else
			if(!("MC" in target.panel_tabs) || !("Tickets" in target.panel_tabs))
				target << output("", "statbrowser:add_admin_tabs")
			target << output("[target.prefs.split_admin_tabs]", "statbrowser:update_split_admin_tabs")
			if(target.holder.rights & R_ADMIN && target.stat_tab == "MC")
				var/turf/eye_turf = get_turf(target.eye)
				var/coord_entry = url_encode(COORD(eye_turf))
				if(!mc_data_encoded)
					generate_mc_data()
				if(target.holder.rights & R_DEBUG)
					target << output("[mc_data_encoded];[coord_entry]", "statbrowser:update_mc")
				else
					target << output("[mc_data_for_admins_encoded];[coord_entry]", "statbrowser:update_mc")
			if(target.stat_tab == "Tickets")
				var/list/ahelp_tickets = global.ahelp_tickets.stat_entry()
				target << output("[url_encode(json_encode(ahelp_tickets))];", "statbrowser:update_tickets")
		if(target.mob?.listed_turf)
			var/mob/target_mob = target.mob
			if(!target_mob.TurfAdjacent(target_mob.listed_turf))
				target << output("", "statbrowser:remove_listedturf")
				target_mob.listed_turf = null
			else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
				var/list/overrides = list()
				var/list/turfitems = list()
				for(var/img in target.images)
					var/image/target_image = img
					if(!target_image.loc || target_image.loc.loc != target_mob.listed_turf || !target_image.override)
						continue
					overrides += target_image.loc
				turfitems[++turfitems.len] = list("[target_mob.listed_turf]", ref(target_mob.listed_turf), bicon(target_mob.listed_turf))
				for(var/tc in target_mob.listed_turf)
					var/atom/movable/turf_content = tc
					if(turf_content.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
						continue
					if(turf_content.invisibility > target_mob.see_invisible)
						continue
					if(is_type_in_list(turf_content, target_mob.shouldnt_see))
						continue
					if(turf_content in overrides)
						continue
					if(length(turfitems) < 30) // only create images for the first 30 items on the turf, for performance reasons
						if(!(ref(turf_content) in cached_images))
							cached_images += ref(turf_content)
							turf_content.RegisterSignal(turf_content, COMSIG_PARENT_QDELETING, /atom/.proc/remove_from_cache) // we reset cache if anything in it gets deleted
							if(ismob(turf_content) || length(turf_content.overlays) > 2)
								turfitems[++turfitems.len] = list("[turf_content.name]", ref(turf_content), bicon(turf_content))
							else
								turfitems[++turfitems.len] = list("[turf_content.name]", ref(turf_content), bicon(turf_content))
						else
							turfitems[++turfitems.len] = list("[turf_content.name]", ref(turf_content))
					else
						turfitems[++turfitems.len] = list("[turf_content.name]", ref(turf_content))
				turfitems = url_encode(json_encode(turfitems))
				target << output("[turfitems];", "statbrowser:update_listedturf")

		if(MC_TICK_CHECK)
			return

// R_DEBUG
/datum/controller/subsystem/statpanels/proc/generate_mc_data()
	var/list/mc_data = list(
		list("CPU:", world.cpu),
		list("Instances:", "[num2text(world.contents.len, 10)]"),
		list("World Time:", "[world.time]"),
		list("[config]:", config.stat_entry(), "\ref[config]"),
		list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time/world.tick_lag]) (TickDrift:[round(Master.tickdrift,1)]([round((Master.tickdrift/(world.time/world.tick_lag))*100,0.1)]%))"),
		list("Master Controller:", Master.stat_entry(), "\ref[Master]"),
		list("Failsafe Controller:", Failsafe.stat_entry(), "\ref[Failsafe]"),
		list("","")
	)
	for(var/ss in Master.subsystems)
		var/datum/controller/subsystem/sub_system = ss
		mc_data[++mc_data.len] = list("\[[sub_system.state_letter()]][sub_system.name]", sub_system.stat_entry(), "\ref[sub_system]")
	mc_data[++mc_data.len] = list("Camera Net", "Cameras: [global.cameranet.cameras.len] | Chunks: [global.cameranet.chunks.len]", "\ref[global.cameranet]")
	mc_data_encoded = url_encode(json_encode(mc_data))
	var/list/mc_data_for_admins = list(
		list("CPU:", world.cpu),
	)
	mc_data_for_admins_encoded = url_encode(json_encode(mc_data_for_admins))

/atom/proc/remove_from_cache()
	SIGNAL_HANDLER
	SSstatpanels.cached_images -= ref(src)

/// verbs that send information from the browser UI
/client/verb/set_tab(tab as text|null)
	set name = "Set Tab"
	set hidden = TRUE

	stat_tab = tab

/client/verb/send_tabs(tabs as text|null)
	set name = "Send Tabs"
	set hidden = TRUE

	panel_tabs |= tabs

/client/verb/remove_tabs(tabs as text|null)
	set name = "Remove Tabs"
	set hidden = TRUE

	panel_tabs -= tabs

/client/verb/panel_ready()
	set name = "Panel Ready"
	set hidden = TRUE

	statbrowser_ready = TRUE
	init_verbs()

/client/verb/update_verbs()
	set name = "Update Verbs"
	set hidden = TRUE

	init_verbs()

