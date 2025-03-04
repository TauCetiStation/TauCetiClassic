#define SAMOSBOR_CACHE_FOLDER "cache/samosbor"
#define SAMOSBOR_CACHE_PATH(suffix) "[SAMOSBOR_CACHE_FOLDER]/milestones_[suffix].txt"

SUBSYSTEM_DEF(samosbor)
	name = "Samosbor"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_FIRE

	var/next_milestone = 10 // players online when we send the next notification
	var/milestone_step = 10
	var/bridge_announce_milestone = 30

	var/day
	var/day_shift = 4 HOURS // starts day at 4 am

	var/notfication_timer

/datum/controller/subsystem/samosbor/Initialize()
	if(!config.chat_bridge)
		return ..()

	day = time2text(world.realtime - day_shift, "YYYY_MM_DD")

	var/cache_path = SAMOSBOR_CACHE_PATH(day)
	if(fexists(cache_path))
		var/cached_milestone = text2num(trim(file2text(cache_path)))

		if(isnum(cached_milestone) && cached_milestone >= (next_milestone + milestone_step))
			next_milestone = cached_milestone
		else
			fdel(cache_path)

	RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))

	return ..()

/datum/controller/subsystem/samosbor/proc/client_connected(datum/source, client/connected)
	SIGNAL_HANDLER

	var/players_online = length(global.clients)
	if(players_online >= next_milestone)
		INVOKE_ASYNC(src, PROC_REF(milestone_reached), players_online)

/datum/controller/subsystem/samosbor/proc/milestone_reached(players_online)
	var/current_milestone = max(next_milestone, players_online - (players_online % milestone_step))
	next_milestone = current_milestone + milestone_step

	var/cache_path = SAMOSBOR_CACHE_PATH(day)
	fdel(cache_path)
	text2file(num2text(next_milestone), cache_path) // note: delete previous days files, todo or do it with host tools

	// 30 seconds timer so we don't spam it at the start of the round
	notfication_timer = addtimer(CALLBACK(src, PROC_REF(milestone_notification), current_milestone), 30 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/controller/subsystem/samosbor/proc/milestone_notification(milestone)
	var/list/bridge_type = list(BRIDGE_SAMOSBOR)
	if(milestone >= bridge_announce_milestone)
		bridge_type += BRIDGE_ANNOUNCE
	world.send2bridge(
		type = bridge_type,
		attachment_title = "Новый результат на сегодня: более [milestone] игроков онлайн!",
		attachment_msg = BRIDGE_JOIN_LINKS
	)

#undef SAMOSBOR_CACHE_FOLDER
#undef SAMOSBOR_CACHE_PATH
