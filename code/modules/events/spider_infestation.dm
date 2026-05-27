/datum/event/spider_infestation
	announceWhen = 400
	announcement = new /datum/announcement/centcomm/aliens
	var/spawncount = 1

/datum/event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(4 * severity, 6 * severity)

/datum/event/spider_infestation/start()
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn spiders but no suitable vents were found. Shutting down.")
		return

	var/list/spawned_spiderlings = list()
	while(spawncount >= 1)
		var/obj/vent = pick(vents)
		spawned_spiderlings += new /obj/structure/spider/spiderling(vent.loc)
		vents -= vent
		spawncount--

	if(length(spawned_spiderlings))
		var/obj/structure/spider/spiderling/S = pick(spawned_spiderlings)
		notify_ghosts("Spider infestation!", source = S, action = NOTIFY_ORBIT, header = "Spider Infestation")
