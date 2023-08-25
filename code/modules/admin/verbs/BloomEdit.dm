/client/proc/debug_bloom() // todo: make this hidden under debug verbs, we can't trust admins
	set name = "Bloom Edit"
	set category = "Debug"

	if(!check_rights(R_VAREDIT)) // todo: debug
		return

	if(!holder.debug_bloom)
		holder.debug_bloom = new /datum/bloom_edit(src)

	holder.debug_bloom.tgui_interact(usr)

	message_admins("[key_name(src)] opened Bloom Edit panel.")
	log_admin("[key_name(src)] opened Bloom Edit panel.")

/datum/bloom_edit

/datum/bloom_edit/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BloomEdit", "Bloom Edit")
		ui.open()

/datum/bloom_edit/tgui_data(mob/user)
	var/list/data = list()

	data["glow_base"] = global.GLOW_BASE
	data["glow_power"] = global.GLOW_POWER
	data["exposure_base"] = global.EXPOSURE_BASE
	data["exposure_power"] = global.EXPOSURE_POWER

	return data

/datum/bloom_edit/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("glow_base")
			global.GLOW_BASE = clamp(params["value"], -5, 5)
		if("glow_power")
			global.GLOW_POWER = clamp(params["value"], -5, 5)
		if("exposure_base")
			global.EXPOSURE_BASE = clamp(params["value"], -5, 5)
		if("exposure_power")
			global.EXPOSURE_POWER = clamp(params["value"], -5, 5)
		if("default")
			global.GLOW_BASE = initial(global.GLOW_BASE)
			global.GLOW_POWER = initial(global.GLOW_POWER)
			global.EXPOSURE_BASE = initial(global.EXPOSURE_BASE)
			global.EXPOSURE_POWER = initial(global.EXPOSURE_POWER)
		if("update_lamps") // todo: make this update all objects with glow
			for(var/obj/machinery/light/L in machines)
				if(L.lampimage || L.exposureimage)
					//L.update_light() // does nothing
					L.set_light(0) // so we make this ugly way
					L.update_now()

	return TRUE

/datum/bloom_edit/tgui_state(mob/user)
	return global.admin_state
