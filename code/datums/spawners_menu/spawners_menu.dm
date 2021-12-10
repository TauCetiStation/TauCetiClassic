/datum/spawners_menu
	var/mob/dead/observer/owner

/datum/spawners_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/spawners_menu/Destroy()
	owner = null
	return ..()

/datum/spawners_menu/tgui_state(mob/user)
	return global.observer_state

/datum/spawners_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/spawners_menu/tgui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner_type in global.spawners)
		var/list/this = list()
		var/list/spawners_list = global.spawners[spawner_type]
		var/datum/spawner/spawner = pick(spawners_list)
		this["type"] = spawner_type
		this["name"] = spawner.name
		this["short_desc"] = spawner.desc
		this["flavor_text"] = spawner.flavor_text
		this["important_warning"] = spawner.important_info
		this["amount_left"] = spawners_list.len

		var/min_time = INFINITY
		for(var/datum/spawner/S as anything in spawners_list)
			if(!S.timer_to_expiration)
				continue
			if(timeleft(S.timer_to_expiration) < min_time)
				min_time = timeleft(S.timer_to_expiration)

		this["time_left"] = min_time

		data["spawners"] += list(this)
	return data

/datum/spawners_menu/tgui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/spawner_type = text2path(params["type"])
	if(!(spawner_type in global.spawners))
		return

	var/list/spawnerlist = global.spawners[spawner_type]
	if(!spawnerlist.len)
		return

	var/datum/spawner/spawner = pick(spawnerlist)
	if(!spawner)
		return

	switch(action)
		if("jump")
			spawner.jump(owner)
			to_chat(world, "[action] - [spawner.name] is work")
			return TRUE
		if("spawn")
			spawner.do_spawn(owner)
			to_chat(world, "[action] - [spawner.name] is work")
			return TRUE
