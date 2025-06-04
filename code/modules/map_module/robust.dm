/datum/map_module/robust
	name = MAP_MODULE_ROBUST

	default_event_name = "Robust"
	default_event_message = {"Межгалактический Турнир по Робасту!"}

	gamemode = "Extended"
	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE
	disable_default_spawners = TRUE

	admin_verbs = list(
		/client/proc/choose_station_size,
		/client/proc/robust_assign_commentator,
	)

	var/list/datum/spawner/robust/spawners = list()

	var/station_size = "Small"

	var/list/jobs_unique_to_big_station = list("Robust Kitchen Chef", "Robust Bartender", "Robust Engineer", "Robust Clown", "Robust Security", "Robust Janitor Borg")

/datum/map_module/robust/New()
	..()
	config.health_threshold_softcrit = -20 // 0 by default
	config.health_threshold_crit = -70 // -50 by default
	config.organ_health_multiplier = 1.25 // 1 by default
	// show must go on!

	spawners["Robust Visitor"] = create_spawner(/datum/spawner/robust, src)
	spawners["Robust Janitor"] = create_spawner(/datum/spawner/robust/janitor, src)
	spawners["Robust Doctor"] = create_spawners(/datum/spawner/robust/doctor, 2, src)

/* admin verbs */
/client/proc/choose_station_size()
	set category = "Event"
	set name = "Robust: Choose Station Size"

	var/datum/map_module/robust/MM = SSmapping.get_map_module(MAP_MODULE_ROBUST)

	var/list/robust_station_sizes = list("Small","Big","Cancel")

	var/new_station_size = tgui_input_list(src,"Small (10-25 players) or Big (25-60 players)?", "Choose Station Size", robust_station_sizes)

	if(MM.station_size == new_station_size)
		to_chat(src, "Этот размер станции уже выбран.")
	else if(new_station_size == "Small")
		MM.station_size = new_station_size
		message_admins("[key_name(src)] changed robust station size to [new_station_size].")
		for(var/jobname in MM.jobs_unique_to_big_station)
			if(MM.spawners[jobname])
				MM.spawners[jobname].Destroy()
	else if(new_station_size == "Big")
		MM.station_size = new_station_size
		message_admins("[key_name(src)] changed robust station size to [new_station_size].")
		MM.spawners["Robust Kitchen Chef"] = create_spawner(/datum/spawner/robust/chef, MM)
		MM.spawners["Robust Bartender"] = create_spawner(/datum/spawner/robust/bartender, MM)
		MM.spawners["Robust Engineer"] = create_spawner(/datum/spawner/robust/engineer, MM)
		MM.spawners["Robust Clown"] = create_spawner(/datum/spawner/robust/clown, MM)
		MM.spawners["Robust Security"] = create_spawners(/datum/spawner/robust/security, 2, MM)
		MM.spawners["Robust Janitor Borg"] = create_spawner(/datum/spawner/robust/janitorborg, MM)

/client/proc/robust_assign_commentator()
	set category = "Event"
	set name = "Robust: Assign Commentator"

	var/datum/map_module/robust/MM = SSmapping.get_map_module(MAP_MODULE_ROBUST)
	var/list/candidates = list()

	for(var/mob/dead/spectator in player_list)
		if(!spectator || !spectator.client)
			continue
		candidates["[spectator.client]"] = spectator

	var/new_commentator = tgui_input_list(src,"Choose member to become a Commentator:", "Assign Commentator", candidates)

	if(!new_commentator)
		return

	message_admins("[key_name(src)] assigned [candidates[new_commentator]] as Commentator.")

	MM.spawners["Robust Commentator"] = create_spawner(/datum/spawner/robust/commentator, MM)
	MM.spawners["Robust Commentator"].registration(candidates[new_commentator])

// for doctors to rejuv guys faster
/obj/item/weapon/strangetool/robust
	name = "healing device"
	desc = "This device is made of metal, emits a strange purple formation. Truly a wonder of NanoTrasen technology!"

/obj/item/weapon/strangetool/robust/emmit_healing(mob/M)
	if(last_time_used + 5 < world.time)
		visible_message("<span class='notice'><font color='purple'>[bicon(src)]Device blinks brightly.</font></span>")
		if(isliving(M))
			var/mob/living/C = M
			C.rejuvenate()
			to_chat(C, "<span class='notice'><font color='blue'>You feel a soothing energy invigorate you.</font></span>")
		last_time_used = world.time
	else
		visible_message("<span class='notice'><font color='red'>[bicon(src)] Device blinks faintly.</font></span>")
