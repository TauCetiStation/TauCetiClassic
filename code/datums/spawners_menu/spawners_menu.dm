/datum/spawners_menu
	var/mob/dead/observer/owner

	var/role_selected = FALSE

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

	var/askRole = user?.client?.be_ghost_candidate
	data["askForRole"] = askRole ? 1 : 0

	data["ignoredRoles"] = list()
	var/list/ignored = user?.client?.prefs?.ignore_question
	for(var/role in (full_ignore_question | ignored))
		if(role)
			var/list/this = list()
			this["name"] = role
			this["ignored"] = (role in ignored)
			data["ignoredRoles"] |= list(this)

	data["spawners"] = list()
	for(var/spawner_id in global.spawners)
		var/list/this = list()
		var/list/spawners_list = global.spawners[spawner_id]
		var/datum/spawner/spawner = pick(spawners_list)
		this["type"] = spawner_id
		this["name"] = spawner.name
		this["short_desc"] = spawner.desc
		this["wiki_ref"] = config.wikiurl && spawner.wiki_ref ? "[config.wikiurl]/[spawner.wiki_ref]" : null
		this["important_warning"] = spawner.important_info
		this["amount_left"] = spawners_list.len
		this["is_infinite"] = spawner.infinity
		this["toggleable"] = spawner.toggleable
		this["switched_on"] = spawner.is_switched_on(user)

		var/min_time = INFINITY
		for(var/datum/spawner/S as anything in spawners_list)
			if(!S.timer_to_expiration)
				continue
			var/time_left = timeleft(S.timer_to_expiration)
			if(time_left < min_time)
				min_time = time_left

		this["time_left"] = min_time != INFINITY ? min_time : null

		data["spawners"] += list(this)

	return data

/datum/spawners_menu/tgui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(role_selected)
		to_chat(owner, "<span class='notice'>Вы уже выбрали роль!</span>")
		return

	var/datum/spawner/spawner
	if("type" in params)
		var/spawner_id = params["type"]
		if(!(spawner_id in global.spawners))
			return

		var/list/spawnerlist = global.spawners[spawner_id]
		if(!spawnerlist.len)
			return

		spawner = pick(spawnerlist)
		if(!spawner)
			return

	switch(action)
		if("jump")
			spawner.jump(owner)
			return TRUE
		if("spawn")
			role_selected = TRUE
			spawner.do_spawn(owner)
			role_selected = FALSE
			return TRUE
		if("toggle")
			spawner.toggleChoice(owner)
			return TRUE
		if("askForRole")
			if(owner?.client)
				owner.client.be_ghost_candidate = !owner.client.be_ghost_candidate
			return TRUE
		if("unignore")
			var/role = params["role"]
			var/ignore = params["ignore"]
			if(role && (ignore != null) && owner?.client?.prefs?.ignore_question)
				if(ignore)
					owner.client.prefs.ignore_question |= role
				else
					owner.client.prefs.ignore_question -= role
			return TRUE
