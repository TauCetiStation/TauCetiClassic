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
	var/list/alive = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	var/list/pois = getpois(mobs_only = FALSE, skip_mindless = FALSE)
	for(var/name in pois)
		var/list/serialized = list()
		serialized["name"] = name

		var/poi = pois[name]

		serialized["ref"] = "\ref[poi]"

		var/mob/M = poi
		if(istype(M))
			if (isobserver(M))
				ghosts += list(serialized)
			else if(M.stat == DEAD)
				dead += list(serialized)
			else if(M.mind == null)
				npcs += list(serialized)
			else
				alive += list(serialized)

				var/mob/dead/observer/O = user
				if(O.antagHUD)
					for(var/mob/A in mob_list - observer_list)
						if(A.mind?.special_role)
							var/antag_serialized = serialized.Copy()
							antag_serialized["antag"] = A.mind.special_role
							antagonists += list(antag_serialized)


		else
			misc += list(serialized)

	data["alive"] = alive
	data["dead"] = dead
	data["antagonists"] = antagonists
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data
