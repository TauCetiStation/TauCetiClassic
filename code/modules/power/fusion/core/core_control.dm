/obj/machinery/computer/fusion_core_control
	name = "R-UST Mk. 8 core control"
	icon = 'icons/obj/machines/power/fusion.dmi'
	icon_state = "core_control"
	light_color = COLOR_ORANGE

	var/id_tag
	var/scan_range = 25
	var/list/connected_devices = list()
	var/obj/machinery/power/fusion_core/cur_viewed_device

/obj/machinery/computer/fusion_core_control/attackby(obj/item/thing, mob/user)
	if(ismultitool(thing))
		var/new_ident = sanitize_safe(input("Enter a new ident tag.", "Core Control", input_default(id_tag)) as null|text, MAX_LNAME_LEN)
		if(new_ident && user.Adjacent(src))
			id_tag = new_ident
			cur_viewed_device = null
		return
	else
		return ..()

/obj/machinery/computer/fusion_core_control/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)

	if(stat & BROKEN)
		return

	var/data[0]
	data["idTag"] = id_tag

	if(!cur_viewed_device || !check_core_status(cur_viewed_device))
		cur_viewed_device = null

	if(cur_viewed_device && (cur_viewed_device.id_tag != id_tag || get_dist(src, cur_viewed_device) > scan_range))
		cur_viewed_device = null

	data["fusionCore"] = cur_viewed_device

	var/fusionData[0]

	if(cur_viewed_device)
		fusionData["id_tag"] = cur_viewed_device.id_tag
		fusionData["owned_field"] = cur_viewed_device.owned_field
		fusionData["avail"] = round(cur_viewed_device.avail())
		fusionData["active_power_usage"] = cur_viewed_device.active_power_usage
		fusionData["field_strength"] = cur_viewed_device.field_strength

		var/fieldData[0]

		if(cur_viewed_device.owned_field)

			fieldData["size"] = cur_viewed_device.owned_field.size
			fieldData["instability"] = round(cur_viewed_device.owned_field.percent_unstable * 100)
			fieldData["temperature"] = round(cur_viewed_device.owned_field.plasma_temperature + 295)

			var/reagents[0]

			for(var/reagent in cur_viewed_device.owned_field.reactants)
				reagents[++reagents.len] = list(
					"name" = reagent,
					"amount" = cur_viewed_device.owned_field.reactants[reagent]
					)

			fieldData["reagents"] = reagents

		fusionData["fieldData"] = fieldData

	else
		connected_devices.Cut()
		for(var/obj/machinery/power/fusion_core/C in fusion_cores)
			if(C.id_tag == id_tag && get_dist(src, C) <= scan_range)
				connected_devices += C
		for(var/obj/machinery/power/fusion_core/C in gyrotrons)
			if(C.id_tag == id_tag && get_dist(src, C) <= scan_range)
				connected_devices += C

		var/fusionCores[0]

		if(connected_devices.len)
			for(var/obj/machinery/power/fusion_core/C in connected_devices)
				var/status
				var/can_access = 1

				if(!check_core_status(C))
					status = 2
					can_access = 0
				else if(C.avail() < C.active_power_usage)
					status = 1
				else
					status = 0

				fusionCores[++fusionCores.len] = list(
					"id_tag" = C.id_tag,
					"status" = status,
					"controls" = can_access ? connected_devices.Find(C) : 0
					)
			fusionData["devices"] = fusionCores
		else
			fusionData["devices"] = null

	data["fusionData"] = fusionData

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "fusion_control.tmpl", name, 540, 550)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/fusion_core_control/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["access_device"])
		var/idx = clamp(text2num(href_list["toggle_active"]), 1, connected_devices.len)
		cur_viewed_device = connected_devices[idx]
		updateUsrDialog()

	//All HREFs from this point on require a device anyways.
	else if(!cur_viewed_device || !check_core_status(cur_viewed_device) || cur_viewed_device.id_tag != id_tag || get_dist(src, cur_viewed_device) > scan_range)
		return

	else if(href_list["goto_scanlist"])
		cur_viewed_device = null
		updateUsrDialog()

	else if(href_list["toggle_active"])
		if(!cur_viewed_device.Startup()) //Startup() whilst the device is active will return null.
			cur_viewed_device.Shutdown()
		updateUsrDialog()

	else if(href_list["str"])
		var/val = text2num(href_list["str"])
		if(!val) //Value is 0, which is manual entering.
			cur_viewed_device.set_strength(input("Enter the new field power density (W.m^-3)", "Fusion Control", cur_viewed_device.field_strength) as num)
		else
			cur_viewed_device.set_strength(cur_viewed_device.field_strength + val)
		updateUsrDialog()

//Returns 1 if the machine can be interacted with via this console.
/obj/machinery/computer/fusion_core_control/proc/check_core_status(obj/machinery/power/fusion_core/C)
	if(isnull(C))
		return FALSE
	if(C.stat & BROKEN)
		return FALSE
	if(C.idle_power_usage > C.avail())
		return FALSE
	. = TRUE
