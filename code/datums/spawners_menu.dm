var/global/list/datum/spawners = list()

/datum/spawner
	var/name
	var/desc
	var/flavor_text
	var/important_info

	var/required_pref

	var/datum/callback/spawn_ghost

/datum/spawner/New()
	LAZYADD(global.spawners[type], src)

/datum/spawner/Destroy()
	var/list/spawn_list = global.spawners[type]
	LAZYREMOVE(spawn_list, src)
	if(!length(spawn_list))
		global.spawners -= type
	return ..()

/datum/spawner/proc/do_spawn(mob/dead/observer/ghost)
	if(!can_spawn(ghost))
		return
	spawn_ghost(ghost)

/datum/spawner/proc/can_spawn(mob/dead/observer/ghost)
	if(!ghost.client)
		return FALSE
	if(!required_pref)
		return TRUE
	if(jobban_isbanned(ghost, required_pref) || jobban_isbanned(ghost, "Syndicate") || role_available_in_minutes(ghost, required_pref))
		return FALSE
	return TRUE

/datum/spawner/proc/spawn_ghost(mob/dead/observer/ghost)
	return

/datum/spawner/proc/jump(mob/dead/observer/ghost)
	return

/datum/spawner/dealer
	name = "Контрабандист"
	desc = "Вы появляетесь в космосе вблизи со станцией."
	flavor_text = "https://wiki.taucetistation.org/Families"

	required_pref = ROLE_FAMILIES

/datum/spawner/dealer/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(copsstart) // TODO: dealerstart
	copsstart -= spawnloc // TODO: dealerstart

	var/client/C = ghost.client

	var/mob/living/carbon/human/H = new(null)
	var/new_name = sanitize_safe(input(C, "Pick a name", "Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(H, new_name)

	H.loc = spawnloc
	H.key = C.key

	create_and_setup_role(/datum/role/traitor/dealer, H, TRUE)

/datum/spawner/dealer/jump(mob/dead/observer/ghost)
	var/jump_to = pick(copsstart) // TODO: dealerstart
	ghost.forceMove(get_turf(jump_to))

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
			qdel(spawner)
			return TRUE
