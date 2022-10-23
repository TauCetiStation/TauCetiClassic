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

	while(spawncount >= 1)
		var/obj/vent = pick(vents)
		new /obj/structure/spider/spiderling(vent.loc)
		vents -= vent
		spawncount--
