/datum/orbit_menu
	var/mob/dead/observer/owner

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Orbit", "Orbit Menu", 800, 600)
		ui.open()

/datum/orbit_menu/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("orbit")
			var/ref = params["ref"]

			var/atom/movable/poi = (locate(ref) in global.mob_list) || (locate(ref) in global.poi_list)
			if(poi == null)
				. = TRUE
				return
			owner.ManualFollow(poi)
			. = TRUE
		if("refresh")
			update_static_data(owner, ui)
			. = TRUE

/datum/orbit_menu/tgui_state(mob/user)
	return global.observer_state

/datum/orbit_menu/tgui_data(mob/user)
	var/list/data = list()
	return data

/datum/orbit_menu/tgui_static_data(mob/user)
	var/list/data = list()
	data["misc"] = list()
	data["ghosts"] = list()
	data["dead"] = list()
	data["npcs"] = list()
	data["alive"] = list()
	data["antagonists"] = list()


	var/list/pois = getpois(mobs_only = FALSE, skip_mindless = FALSE)
	for(var/name in pois)
		var/list/serialized = list()
		var/poi = pois[name]

		serialized["name"] = name
		serialized["ref"] = "\ref[poi]"

		var/mob/M = poi
		if(!istype(M))
			data["misc"] += list(serialized)
			continue

		if(isobserver(M))
			data["ghosts"] += list(serialized)
			continue

		if(M.stat == DEAD)
			data["dead"] += list(serialized)
			continue

		if(M.mind == null)
			data["npcs"] += list(serialized)
			continue

		data["alive"] += list(serialized)

		var/mob/dead/observer/O = user
		if((O.antagHUD || O.client.holder) && isanyantag(M))
			var/antag_serialized = serialized.Copy()
			for(var/antag_category in M.mind.antag_roles)
				antag_serialized["antag"] += list(antag_category)
			data["antagonists"] += list(antag_serialized)

	return data
