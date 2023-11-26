/datum/spawners_menu
	var/mob/dead/owner

/datum/spawners_menu/New(mob/dead/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/spawners_menu/Destroy()
	owner = null
	return ..()

/datum/spawners_menu/tgui_state(mob/user)
	return global.spectator_state

/datum/spawners_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu")
		//ui.set_autoupdate(FALSE)
		ui.open()

/datum/spawners_menu/tgui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/datum/spawner/spawner in SSrole_spawners.spawners)
		var/list/this = list()
		this["ref"] = "\ref[spawner]"
		this["name"] = spawner.name
		this["short_desc"] = spawner.desc
		this["wiki_ref"] = config.wikiurl && spawner.wiki_ref ? "[config.wikiurl]/[spawner.wiki_ref]" : null
		this["important_warning"] = spawner.important_info
		this["register_only"] = spawner.register_only
		this["checked"] = (user in spawner.registered_candidates)
		this["blocked"] = spawner.blocked

		this["amount"] = ""
		if(spawner.register_only)
			this["amount"] += "[length(spawner.registered_candidates)]/"
		this["amount"] += "[spawner.positions == INFINITY ? "∞" : spawner.positions]"

		var/time
		var/time_type
		if(spawner.registration_timer_id)
			time = timeleft(spawner.registration_timer_id)
			time_type = 1
		else if(spawner.availability_timer_id)
			time = timeleft(spawner.availability_timer_id)
			time_type = 2

		if(time)
			this["time_left"] = time
			this["time_type"] = time_type

		data["spawners"] += list(this)
	return data

/datum/spawners_menu/tgui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(!owner.client || owner.client.is_in_spawner)
		to_chat(owner, "<span class='notice'>Вы уже выбрали роль!</span>")
		return

/*	var/spawner_id = params["type"]
	if(!(spawner_id in global.spawners))
		return

	var/list/spawnerlist = global.spawners[spawner_id]
	if(!spawnerlist.len)
		return

	var/datum/spawner/spawner = pick(spawnerlist)
	*/

	var/datum/spawner/spawner = locate(params["ref"]) in SSrole_spawners.spawners

	if(!spawner)
		return

	switch(action)
		if("jump")
			spawner.jump(owner)
			return TRUE
		if("spawn")
			spawner.registration(owner)
			return TRUE
